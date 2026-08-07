/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     revenmartin <revenmartin@gmail.com>
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
 
import QtQuick 6.0
import QtQuick.Layouts 6.0
import QtQuick.Controls 6.0
import Qt5Compat.GraphicalEffects 6.0
import FishUI 1.0 as FishUI

FishUI.MenuPopupWindow {
    id: control

    // 重要：菜单窗口默认隐藏，直到 show()/popup() 才显示。
    // 若不加这一行，QML 实例化窗口对象时 X 窗口会被映射为可见，
    // 堆叠在屏幕左上角并拦截鼠标事件（覆盖桌面/应用）。
    visible: false

    default property alias content : _mainLayout.data

    Rectangle {
        id: _background
        anchors.fill: parent
        color: FishUI.Theme.secondBackgroundColor
        radius: windowHelper.compositing ? FishUI.Theme.hugeRadius : 0
        opacity: windowHelper.compositing ? 0.6 : 1
        border.color: _background.borderColor
        border.width: 1 / FishUI.Units.devicePixelRatio
        border.pixelAligned: FishUI.Units.devicePixelRatio > 1 ? false : true

        property var borderColor: windowHelper.compositing ? FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.3)
                                                                      : Qt.rgba(0, 0, 0, 0.2) : FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.1)
                                                                                                                      : Qt.rgba(0, 0, 0, 0.05)

        FishUI.WindowHelper {
            id: windowHelper
        }

        FishUI.WindowShadow {
            view: control
            geometry: Qt.rect(control.x, control.y, control.width, control.height)
            radius: _background.radius
        }

        FishUI.WindowBlur {
            view: control
            geometry: Qt.rect(control.x, control.y, control.width, control.height)
            windowRadius: _background.radius
            enabled: true
        }
    }

    ColumnLayout {
        id: _mainLayout
        anchors.fill: parent
        anchors.topMargin: 4
        anchors.bottomMargin: 4

        // 内容（菜单项）按背景圆角裁剪：
        // 修复迁移 Qt6 后菜单项高亮（默认矩形）在背景圆角处显示直角、角超出菜单的问题
        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                radius: _background.radius
                width: _mainLayout.width
                height: _mainLayout.height
            }
        }
    }

    // 修复：QML 的 default property alias 覆盖了 C++ 的 DefaultProperty
    // (popupContentItem)，导致 m_contentItem 为 null，MenuPopupWindow::show()
    // 中解引用空指针段错误。这里在子项创建完成后显式设置内容容器。
    Component.onCompleted: {
        control.popupContentItem = _mainLayout
    }

    function open() {
        control.show()
    }

    function popup() {
        control.show()
    }

    // 指定位置弹出（供 FishUI.MenuItem 的子菜单使用）
    function popupAt(x, y) {
        control.popup(x, y)
    }
}
