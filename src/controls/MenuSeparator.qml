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
import QtQuick.Layouts 1.15

// 统一菜单分隔线：与 FishUI.DesktopMenu / FishUI.MenuItem 配套使用。
// 不依赖 QtQuick.Controls 的 style 解析（系统菜单样式与桌面右键菜单完全一致）。
// 行高 9px（上下各 4px 呼吸空间），1px 细线，水平方向内缩 12px。
Item {
    id: control

    readonly property bool isDark: Qt.styleHints.colorScheme === Qt.ColorScheme.Dark

    // 在 ColumnLayout 中自动拉伸到菜单宽度（宽度不参与菜单宽度计算）
    Layout.fillWidth: true
    implicitHeight: 9
    implicitWidth: 0

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        height: 1
        color: control.isDark ? Qt.rgba(255, 255, 255, 0.18)
                              : Qt.rgba(0, 0, 0, 0.12)
    }
}
