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

#include "menupopupwindow.h"
#include <QGuiApplication>
#include <QQuickRenderControl>
#include <QQuickItem>
#include <QSGRendererInterface>
#include <QScreen>
#include <QTimer>
#include <QKeyEvent>

// X11 窗口类型（KWindowSystem，fishui 构建时可选链接 KF6::WindowSystem）
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
#include <KX11Extras>
#endif

MenuPopupWindow::MenuPopupWindow(QQuickWindow *parent)
    : QQuickWindow(parent)
    , m_parentItem(0)
    , m_contentItem(0)
    , m_mouseMoved(false)
    , m_dismissed(false)
{
    setFlags(Qt::Popup);
    setColor(Qt::transparent);
    connect(qApp, SIGNAL(applicationStateChanged(Qt::ApplicationState)),
            this, SLOT(applicationStateChanged(Qt::ApplicationState)));
}

void MenuPopupWindow::applicationStateChanged(Qt::ApplicationState state)
{
    if (state != Qt::ApplicationActive)
        dismissPopup();
}

void MenuPopupWindow::show()
{
    QPoint pos = QCursor::pos();
    showAt(pos.x(), pos.y());
}

void MenuPopupWindow::showAt(int x, int y)
{
    const int margin = 6;
    // 窗口尺寸直接取自 QML 内容容器（DesktopMenu 已在 recompute() 中把
    // implicitWidth/implicitHeight 算为「可见内容 + 四周 6px 内边距」），
    // 不再额外 +16px —— 原先的 +16 会在菜单底部留下不对称的空白。
    int w = m_contentItem->implicitWidth();
    int h = m_contentItem->implicitHeight();
    int posx = x;
    int posy = y;
    QWindow *pw = transientParent();
    if (!pw && parentItem())
        pw = parentItem()->window();
    if (!pw)
        pw = this;

    QRect g = pw->screen()->availableGeometry();

    if (posx + w > g.right()) {
        if (qobject_cast<MenuPopupWindow *>(transientParent())) {
            // reposition submenu window on the parent menu's left side
            int submenuOverlap = pw->x() + pw->width() - posx;
            posx -= pw->width() + w - 2 * submenuOverlap;
        } else {
            posx = g.right() - w - margin;
        }
    } else {
        posx = qMax(posx, g.left() + margin);
    }

    m_mouseMoved = false;
    m_dismissed = false;

    posy = qBound(g.top(), posy, g.bottom() - h - margin);

    setGeometry(posx, posy, w, h);

    if (QGuiApplication::platformName() == "xcb") {
#if QT_VERSION >= QT_VERSION_CHECK(6, 0, 0)
        KX11Extras::setType(winId(), NET::PopupMenu);
#endif
    }

    QQuickWindow::show();
    setMouseGrabEnabled(true);
    setKeyboardGrabEnabled(true);
}

void MenuPopupWindow::closeAllMenus()
{
    const auto windows = QGuiApplication::topLevelWindows();
    for (QWindow *window : windows) {
        if (auto *menu = qobject_cast<MenuPopupWindow *>(window))
            menu->dismissPopup();
    }
}

void MenuPopupWindow::setParentMenu(QQuickWindow *parentMenu)
{
    if (parentMenu)
        setTransientParent(parentMenu);
}

void MenuPopupWindow::setParentItem(QQuickItem *item)
{
    m_parentItem = item;
    // 不设置 transient parent：菜单是独立弹窗（POPUP_MENU 类型），
    // 避免 KWin 将其归入桌面窗口（壁纸/图标层）的堆叠层，
    // 否则会出现“菜单与壁纸互斥”的问题。
    // 屏幕几何在 popup() 中回退到 parentItem()->window()，多屏定位不受影响。
    // if (m_parentItem)
    //     setTransientParent(m_parentItem->window());
}

void MenuPopupWindow::setPopupContentItem(QQuickItem *contentItem)
{
    if (!contentItem)
        return;

    contentItem->setParentItem(this->contentItem());
    m_contentItem = contentItem;

    connect(contentItem, &QQuickItem::implicitWidthChanged, this, &MenuPopupWindow::updateGeometry);
    connect(contentItem, &QQuickItem::implicitHeightChanged, this, &MenuPopupWindow::updateGeometry);
}

void MenuPopupWindow::dismissPopup()
{
    m_dismissed = true;
    emit popupDismissed();
    hide();
}

void MenuPopupWindow::updateGeometry()
{
    int w = m_contentItem->implicitWidth();
    int h = m_contentItem->implicitHeight();
    int posx = geometry().x();
    int posy = geometry().y();

    setGeometry(posx, posy, w, h);
}

void MenuPopupWindow::mouseMoveEvent(QMouseEvent *e)
{
    m_mouseMoved = true;

    QQuickWindow::mouseMoveEvent(e);
}

void MenuPopupWindow::keyPressEvent(QKeyEvent *e)
{
    // 修复：Escape 关闭菜单窗口。此前 Escape 事件只传给 QML 层，
    // 而 QML 层的 Popup 关闭不会隐藏本 C++ 窗口，导致菜单窗口残留
    // 覆盖桌面，后续右键事件被残留窗口拦截（表现为右键菜单"失效"）。
    if (e->key() == Qt::Key_Escape) {
        dismissPopup();
        e->accept();
        return;
    }
    QQuickWindow::keyPressEvent(e);
}

void MenuPopupWindow::mousePressEvent(QMouseEvent *e)
{
    QRect rect = QRect(QPoint(), size());
    if (rect.contains(e->pos())) {
        QQuickWindow::mousePressEvent(e);
    } else {
        dismissPopup();
    }
}

void MenuPopupWindow::mouseReleaseEvent(QMouseEvent *e)
{
    QRect rect = QRect(QPoint(), size());
    if (rect.contains(e->pos())) {
        // 修复：始终把 release 事件转发给 QML，让菜单项收到完整的
        // press+release（click）事件，从而触发 onTriggered。
        // 原实现只在 m_mouseMoved(发生过移动)时才转发 release，
        // 导致普通点击(无移动)菜单项收不到 release，点击无反应。
        QQuickWindow::mouseReleaseEvent(e);

        // 左键点击菜单项后关闭整个菜单链（父菜单 + 子菜单）
        if (e->button() == Qt::LeftButton && !m_dismissed) {
            closeAllMenus();
        }
    } else {
        // 点击菜单外部：关闭菜单
        dismissPopup();
    }
    m_mouseMoved = true;
}

bool MenuPopupWindow::event(QEvent *event)
{
    //QTBUG-45079
    //This is a workaround for popup menu not being closed when using touch input.
    //Currently mouse synthesized events are not created for touch events which are
    //outside the qquickwindow.

    if (event->type() == QEvent::TouchBegin && !qobject_cast<MenuPopupWindow*>(transientParent())) {
        QRect rect = QRect(QPoint(), size());
        QTouchEvent *touch = static_cast<QTouchEvent*>(event);
        QTouchEvent::TouchPoint point = touch->touchPoints().first();
        if ((point.state() == Qt::TouchPointPressed) && !rect.contains(point.pos().toPoint())) {
          //first default handling
          bool result = QQuickWindow::event(event);
          //now specific broken case
          if (!m_dismissed)
              dismissPopup();
          return result;
        }
    }

    return QQuickWindow::event(event);
}
