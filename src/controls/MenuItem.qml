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

import QtQuick 6.0
import QtQuick.Controls 6.0 as T

// 统一菜单项：与 FishUI.DesktopMenu 配合使用。
// 统一菜单机制的一部分：
//   - 外观由 fish-style 统一渲染（圆角/暗色模式一致）
//   - 支持子菜单（FishUI.DesktopMenu 实例）：hover 或点击在右侧展开
//   - 点击普通项后由 MenuPopupWindow(C++) 统一关闭整个菜单链
// 注意：本文件属于 FishUI 模块内部，禁止 `import FishUI`（会造成 QML 模块循环依赖）。
T.MenuItem {
    id: control

    // 子菜单（FishUI.DesktopMenu 实例）
    property var submenu: null

    readonly property bool hasSubmenu: submenu != null

    hoverEnabled: true

    // 圆角高亮背景：修复迁移 Qt6 后默认 MenuItem 高亮为矩形（方角）的问题
    background: Rectangle {
        implicitWidth: 200
        implicitHeight: 32
        radius: 10
        color: control.pressed || control.highlighted
               ? Qt.rgba(control.palette.highlight.r / 255,
                         control.palette.highlight.g / 255,
                         control.palette.highlight.b / 255, 0.35)
               : control.hovered ? Qt.rgba(0, 0, 0, 0.1) : "transparent"
    }

    // 子菜单箭头
    arrow: Text {
        visible: control.hasSubmenu
        text: "\u203A"
        color: control.palette.text
        opacity: control.enabled ? 0.7 : 0.4
        font.pointSize: 10
    }

    // 点击子菜单项展开子菜单；普通项的关闭由 MenuPopupWindow 统一处理
    onClicked: {
        if (control.hasSubmenu)
            control.openSubmenu()
    }

    // hover 到子菜单项时展开子菜单
    onHoveredChanged: {
        if (control.hovered && control.hasSubmenu)
            control.openSubmenu()
    }

    function openSubmenu() {
        if (!control.submenu)
            return

        var pos = control.mapToGlobal(Qt.point(0, 0))
        control.submenu.popupAt(pos.x + control.width, pos.y)
    }
}
