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
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects 6.0

// 统一菜单项：与 FishUI.DesktopMenu 配合使用。
// Cutefish 右键菜单统一风格设计：
//   - 固定行高 30px；悬停/按下显示圆角胶囊高亮（上下留 2px，左右由菜单内边距留白）
//   - 菜单宽度由最长文字自适应（TextMetrics 度量），不再固定 200px 造成大片留白
//   - 图标 16px + 文字 14px 垂直居中；checkable 项左侧显示主题色勾选标记
//   - 子菜单箭头右对齐（保留 T.MenuItem.arrow 子控件，避免旧版"箭头堆在左上角"的问题）
// 注意：本文件属于 FishUI 模块内部，禁止 `import FishUI`（会造成 QML 模块循环依赖）。
T.MenuItem {
    id: control

    // 子菜单（FishUI.DesktopMenu 实例）
    property var submenu: null
    readonly property bool hasSubmenu: submenu != null

    // 在 ColumnLayout 中自动拉伸到菜单宽度，保证所有菜单项等宽对齐
    Layout.fillWidth: true

    // 主题色（与 FishUI.Theme 一致；菜单由独立 MenuPopupWindow 承载，palette 不可靠）
    readonly property bool isDark: Qt.styleHints.colorScheme === Qt.ColorScheme.Dark
    readonly property color textColor: isDark ? "#F2F3F5" : "#313136"
    readonly property color disabledTextColor: isDark ? "#7A7A84" : "#A6A6B0"
    readonly property color accentColor: isDark ? "#7FC2FF" : "#0176D3"

    // ================= 尺寸 =================
    implicitHeight: 30

    // 宽度 = 勾选区 + 图标区 + 文字 + 子菜单箭头区 + 左右内边距，最小 160
    implicitWidth: {
        var w = 0
        if (control.checkable)
            w += 18
        if (control.icon && control.icon.source)
            w += 16 + 8
        w += textMetrics.advanceWidth
        if (control.hasSubmenu)
            w += 14
        return Math.max(160, w) + control.leftPadding + control.rightPadding
    }

    TextMetrics {
        id: textMetrics
        text: control.text
        font: control.font
    }

    // ================= 布局 =================
    padding: 0
    leftPadding: 8
    rightPadding: 8
    topPadding: 0
    bottomPadding: 0

    hoverEnabled: true

    // 高亮背景：圆角胶囊，上下内缩 2px（左右留白由菜单内边距提供）
    background: Rectangle {
        radius: 7
        color: control.pressed ? (control.isDark ? Qt.rgba(255, 255, 255, 0.16)
                                                 : Qt.rgba(0, 0, 0, 0.12))
               : control.highlighted ? (control.isDark ? Qt.rgba(255, 255, 255, 0.12)
                                                       : Qt.rgba(0, 0, 0, 0.08))
               : control.hovered ? (control.isDark ? Qt.rgba(255, 255, 255, 0.08)
                                                   : Qt.rgba(0, 0, 0, 0.06))
               : "transparent"

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
    }

    // 内容：勾选标记 + 图标 + 文字，垂直居中对齐
    contentItem: Item {
        Image {
            id: menuIcon
            width: 16
            height: 16
            // 必须显式设置 sourceSize：否则 QQuickImageProvider 收到的请求尺寸无效
            // （被 provider 钳成 1x1），返回的 1x1 pixmap 拉伸成 16x16 实心灰块，
            // 表现为"菜单图标是空的"。
            sourceSize: Qt.size(16, 16)
            visible: control.icon && control.icon.source ? control.icon.source.toString().length > 0 : false
            source: control.icon && control.icon.source ? control.icon.source : ""
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        // 图标着色：仅在调用方显式设置 icon.color 时启用（如 dock 的单色线条自定义图标）。
        // 不设置 icon.color（默认 transparent）时保留图标原色——彩色主题图标（folder-new、
        // edit-paste 等）经 image://icontheme 加载后应保持主题配色，不做黑白化。
        ColorOverlay {
            anchors.fill: menuIcon
            source: menuIcon
            color: control.icon && control.icon.color.a > 0 ? control.icon.color : control.textColor
            visible: menuIcon.visible && control.icon && control.icon.color.a > 0
            cached: true
        }

        Text {
            id: checkMark
            visible: control.checkable && control.checked
            text: "\u2713"
            font.pixelSize: 12
            font.bold: true
            color: control.accentColor
            anchors.left: menuIcon.visible ? menuIcon.right : parent.left
            anchors.leftMargin: menuIcon.visible ? 8 : 0
            anchors.verticalCenter: parent.verticalCenter
            width: 18
        }

        Text {
            id: menuText
            text: control.text
            font: control.font
            color: control.enabled ? control.textColor : control.disabledTextColor
            elide: Text.ElideRight
            anchors.left: checkMark.visible ? checkMark.right : menuIcon.visible ? menuIcon.right : parent.left
            anchors.leftMargin: checkMark.visible ? 2 : menuIcon.visible ? 8 : 0
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // 子菜单箭头：右对齐，垂直居中（父对象为菜单项本身，用 x/y 定位）
    arrow: Text {
        visible: control.hasSubmenu
        text: "\u203A"
        color: control.enabled ? control.textColor : control.disabledTextColor
        opacity: 0.7
        font.pixelSize: 16
        x: control.width - control.rightPadding - width - 2
        y: (control.height - height) / 2
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

        // 子菜单的 transient parent 设为父菜单窗口，右缘溢出时自动翻转到父菜单左侧
        control.submenu.setParentMenu(control.submenu.parentMenuRef)

        var pos = control.mapToGlobal(Qt.point(0, 0))
        control.submenu.popupAt(pos.x + control.width, pos.y)
    }
}

