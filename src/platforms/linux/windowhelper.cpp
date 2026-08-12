/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     cutefish <cutefishos@foxmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "windowhelper.h"

#include <QApplication>
#include <QCursor>
#include <KWindowSystem>
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xlib-xcb.h>

#include <memory>

static uint qtEdgesToXcbMoveResizeDirection(Qt::Edges edges)
{
    if (edges == (Qt::TopEdge | Qt::LeftEdge))
        return 0;
    if (edges == Qt::TopEdge)
        return 1;
    if (edges == (Qt::TopEdge | Qt::RightEdge))
        return 2;
    if (edges == Qt::RightEdge)
        return 3;
    if (edges == (Qt::RightEdge | Qt::BottomEdge))
        return 4;
    if (edges == Qt::BottomEdge)
        return 5;
    if (edges == (Qt::BottomEdge | Qt::LeftEdge))
        return 6;
    if (edges == Qt::LeftEdge)
        return 7;

    return 0;
}

WindowHelper::WindowHelper(QObject *parent)
    : QObject(parent)
    , m_moveResizeAtom(0)
    , m_compositing(false)
    , m_softwareRendering(false)
{
    // 检测场景图渲染后端：软件渲染（QSG software）下 layer(FBO) + OpacityMask
    // 会导致 FishUI.Window 的内容无法上屏，Window.qml 据此禁用圆角裁剪。
    // QQuickWindow::sceneGraphBackend() 是静态方法，应用在创建 QGuiApplication
    // 之前调用 QQuickWindow::setSceneGraphBackend() 即可在这里检测到。
    const QString backend = QQuickWindow::sceneGraphBackend();
    m_softwareRendering = (backend.compare(QLatin1String("software"), Qt::CaseInsensitive) == 0);

    // 创建 _NET_WM_MOVERESIZE atom
    xcb_connection_t* connection = x11Connection();
    if (connection) {
        const char* atomName = "_NET_WM_MOVERESIZE";
        xcb_intern_atom_cookie_t cookie = xcb_intern_atom(connection, 0,
                                                          strlen(atomName),
                                                          atomName);
        std::unique_ptr<xcb_intern_atom_reply_t, decltype(&free)>
            reply(xcb_intern_atom_reply(connection, cookie, nullptr), free);

        if (reply) {
            m_moveResizeAtom = reply->atom;
        }
    }

    // Qt6/KDE6: compositingActive() 可能已被移除或改名
    // 暂时设置为true，假设合成器正在运行
    onCompositingChanged(true);
}

bool WindowHelper::compositing() const
{
    return m_compositing;
}

bool WindowHelper::softwareRendering() const
{
    return m_softwareRendering;
}

void WindowHelper::startSystemMove(QWindow *w)
{
    if (!w) return;

    // 优先使用 Qt 内置的 QWindow::startSystemMove()。
    // 它的内部实现会先释放 Qt/QML 当前对指针的抓取（例如 DragHandler
    // 激活时建立的 pointer grab），再向窗口管理器发送移动请求，
    // 确保 WM 能成功抓到指针并正常接收 ButtonRelease 来结束移动。
    // 如果直接发送 _NET_WM_MOVERESIZE 而忘记释放 Qt 的 grab，
    // 会导致：松手后窗口继续跟随鼠标、第二个窗口无法再拖动等问题。
    if (w->startSystemMove()) {
        return;
    }

    // 回退：手动发送 _NET_WM_MOVERESIZE
    doStartSystemMoveResize(w, 16); // move
}

void WindowHelper::startSystemResize(QWindow *w, Qt::Edges edges)
{
    if (!w) return;

    // 与 startSystemMove 同理，优先使用 Qt 内置 API。
    if (w->startSystemResize(edges)) {
        return;
    }

    // 回退：手动发送 _NET_WM_MOVERESIZE
    doStartSystemMoveResize(w, static_cast<int>(edges));
}

void WindowHelper::minimizeWindow(QWindow *w)
{
    if (!w) return;

    // 优先使用 Qt 原生最小化，内部会正确设置窗口状态并通知 WM。
    // 旧实现发送 _NET_WM_STATE_ADD + _NET_WM_STATE_HIDDEN 是错误的：
    // _NET_WM_STATE_HIDDEN 是 WM 标记窗口状态的属性，客户端不能通过
    // 添加该状态来请求最小化，因此最小化按钮点击后没有任何反应。
    w->showMinimized();
}

void WindowHelper::doStartSystemMoveResize(QWindow *w, int edges)
{
    if (!w) return;

    // _NET_WM_MOVERESIZE 要求使用根窗口全局坐标（设备像素）。
    // Qt6 xcb 平台下 QCursor::pos() 返回设备像素坐标（全局坐标），
    // 不要在这里乘以 devicePixelRatio，否则 HiDPI 下坐标会偏移。
    xcb_connection_t *connection = x11Connection();
    xcb_window_t root = x11RootWindow();
    if (!connection || !root) return;

    xcb_client_message_event_t xev{};
    xev.response_type = XCB_CLIENT_MESSAGE;
    xev.type = m_moveResizeAtom;
    xev.format = 32;
    xev.window = w->winId();
    xev.data.data32[0] = QCursor::pos().x();
    xev.data.data32[1] = QCursor::pos().y();

    if (edges == 16)
        xev.data.data32[2] = 8; // move
    else
        xev.data.data32[2] = qtEdgesToXcbMoveResizeDirection(Qt::Edges(edges));

    xev.data.data32[3] = XCB_BUTTON_INDEX_1;
    xev.data.data32[4] = 0;

    // ⚠ 重要：不能调用 xcb_ungrab_pointer！
    // KWin 收到 _NET_WM_MOVERESIZE 后会自行 grab pointer 并进入交互式移动/缩放模式。
    // 主动 ungrab 会破坏 Qt/X11 当前的 pointer grab 状态，导致：
    //   - 窗口被拖出屏幕外/消失
    //   - 拖动过程卡顿
    //   - 后续右键菜单/Popup 卡死
    xcb_send_event(connection, 0, root,
                   XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY,
                   reinterpret_cast<const char*>(&xev));
    // 关键修复：xcb_send_event 只将事件排入输出队列，
    // 必须调用 xcb_flush() 才能真正发送到 X server。
    // 缺少 flush 是窗口无法拖动/调整大小的根因。
    xcb_flush(connection);
}

void WindowHelper::onCompositingChanged(bool enabled)
{
    if (enabled != m_compositing) {
        m_compositing = enabled;
        emit compositingChanged();
    }
}

// ------------------ X11 helpers ------------------

xcb_connection_t* WindowHelper::x11Connection() const
{
    static xcb_connection_t* connection = nullptr;
    if (!connection) {
        Display* display = XOpenDisplay(nullptr);
        if (!display) return nullptr;
        connection = XGetXCBConnection(display);
    }
    return connection;
}

xcb_window_t WindowHelper::x11RootWindow() const
{
    xcb_connection_t* conn = x11Connection();
    if (!conn) return 0;

    const xcb_setup_t* setup = xcb_get_setup(conn);
    xcb_screen_iterator_t iter = xcb_setup_roots_iterator(setup);
    return iter.data->root;
}