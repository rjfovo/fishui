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
{
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

    // onCompositingChanged(KWindowSystem::compositingActive());
    // connect(KWindowSystem::self(), &KWindowSystem::compositingChanged,
    //         this, &WindowHelper::onCompositingChanged);
}

bool WindowHelper::compositing() const
{
    return m_compositing;
}

void WindowHelper::startSystemMove(QWindow *w)
{
    doStartSystemMoveResize(w, 16); // move
}

void WindowHelper::startSystemResize(QWindow *w, Qt::Edges edges)
{
    doStartSystemMoveResize(w, edges);
}

void WindowHelper::minimizeWindow(QWindow *w)
{
    if (!w) return;

    xcb_connection_t* conn = x11Connection();
    xcb_window_t root = x11RootWindow();
    if (!conn || !root) return;

    xcb_atom_t wmStateAtom;
    {
        const char* atomName = "_NET_WM_STATE";
        xcb_intern_atom_cookie_t cookie = xcb_intern_atom(conn, 0, strlen(atomName), atomName);
        std::unique_ptr<xcb_intern_atom_reply_t, decltype(&free)> reply(xcb_intern_atom_reply(conn, cookie, nullptr), free);
        if (!reply) return;
        wmStateAtom = reply->atom;
    }

    xcb_atom_t hiddenAtom;
    {
        const char* atomName = "_NET_WM_STATE_HIDDEN";
        xcb_intern_atom_cookie_t cookie = xcb_intern_atom(conn, 0, strlen(atomName), atomName);
        std::unique_ptr<xcb_intern_atom_reply_t, decltype(&free)> reply(xcb_intern_atom_reply(conn, cookie, nullptr), free);
        if (!reply) return;
        hiddenAtom = reply->atom;
    }

    xcb_client_message_event_t ev{};
    ev.response_type = XCB_CLIENT_MESSAGE;
    ev.window = w->winId();
    ev.format = 32;
    ev.type = wmStateAtom;
    ev.data.data32[0] = 1; // _NET_WM_STATE_ADD
    ev.data.data32[1] = hiddenAtom;
    ev.data.data32[2] = 0;
    ev.data.data32[3] = 0;
    ev.data.data32[4] = 0;

    xcb_send_event(conn, 0, root, XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY, reinterpret_cast<const char*>(&ev));
}


void WindowHelper::doStartSystemMoveResize(QWindow *w, int edges)
{
    if (!w) return;

    const qreal dpiRatio = qApp->devicePixelRatio();
    xcb_connection_t *connection = x11Connection();
    xcb_window_t root = x11RootWindow();
    if (!connection || !root) return;

    xcb_client_message_event_t xev{};
    xev.response_type = XCB_CLIENT_MESSAGE;
    xev.type = m_moveResizeAtom;
    xev.format = 32;
    xev.window = w->winId();
    xev.data.data32[0] = QCursor::pos().x() * dpiRatio;
    xev.data.data32[1] = QCursor::pos().y() * dpiRatio;

    if (edges == 16)
        xev.data.data32[2] = 8; // move
    else
        xev.data.data32[2] = qtEdgesToXcbMoveResizeDirection(Qt::Edges(edges));

    xev.data.data32[3] = XCB_BUTTON_INDEX_1;
    xev.data.data32[4] = 0;

    xcb_ungrab_pointer(connection, XCB_CURRENT_TIME);
    xcb_send_event(connection, 0, root,
                   XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY,
                   reinterpret_cast<const char*>(&xev));
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
