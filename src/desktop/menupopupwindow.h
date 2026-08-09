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

#ifndef MENUPOPUPWINDOW_H
#define MENUPOPUPWINDOW_H

#include <QQuickWindow>
#include <QQuickItem>
#include <QPointer>

class MenuPopupWindow : public QQuickWindow
{
    Q_OBJECT
    Q_PROPERTY(QQuickItem *popupContentItem READ popupContentItem WRITE setPopupContentItem)
    Q_CLASSINFO("DefaultProperty", "popupContentItem")
    Q_PROPERTY(QQuickItem *parentItem READ parentItem WRITE setParentItem)

public:
    MenuPopupWindow(QQuickWindow *parent = nullptr);

    QQuickItem *popupContentItem() const { return m_contentItem; }
    void setPopupContentItem(QQuickItem *popupContentItem);

    QQuickItem *parentItem() const { return m_parentItem; }
    virtual void setParentItem(QQuickItem *);

public slots:
    Q_INVOKABLE void show();
    // 注意：方法名不能用 popup/popupAt —— DesktopMenu.qml 里定义的 QML 函数
    // popup()（无参，弹到鼠标处）与 popupAt()（指定位置）会遮蔽同名 C++ 槽，
    // 导致 popupAt() 内部调用 control.popupAt(x, y) 时实际执行的是 QML 自身（递归）。
    Q_INVOKABLE void showAt(int x, int y);
    // 供子菜单使用：把子菜单的 transient parent 设为父菜单窗口，
    // 这样 showAt() 在贴近屏幕右缘时会自动翻转到父菜单左侧，而不是被钳制到屏幕边缘。
    Q_INVOKABLE void setParentMenu(QQuickWindow *parentMenu);
    Q_INVOKABLE void dismissPopup();
    Q_INVOKABLE void updateGeometry();

    // 关闭当前打开的所有菜单（菜单项触发动作后清理整个菜单链）
    static void closeAllMenus();

signals:
    void popupDismissed();
    void geometryChanged();

protected:
    void keyPressEvent(QKeyEvent *) override;
    void mousePressEvent(QMouseEvent *) override;
    void mouseReleaseEvent(QMouseEvent *) override;
    void mouseMoveEvent(QMouseEvent *) override;
    bool event(QEvent *) override;

protected slots:
    void applicationStateChanged(Qt::ApplicationState state);

private:
    QQuickItem *m_parentItem;
    QPointer<QQuickItem> m_contentItem;
    bool m_mouseMoved;
    bool m_dismissed;
};

// 供 QML 调用的菜单管理器（统一菜单机制：一处关闭所有打开的菜单）
class MenuManager : public QObject
{
    Q_OBJECT
public:
    explicit MenuManager(QObject *parent = nullptr)
        : QObject(parent)
    {
    }

    Q_INVOKABLE void closeAllMenus()
    {
        MenuPopupWindow::closeAllMenus();
    }
};

#endif
