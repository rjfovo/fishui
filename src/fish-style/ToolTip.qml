/*
 * Copyright 2017 Marco Martin <mart@kde.org>
 * Copyright 2017 The Qt Company Ltd.
 *
 * GNU Lesser General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU Lesser
 * General Public License version 3 as published by the Free Software
 * Foundation and appearing in the file LICENSE.LGPLv3 included in the
 * packaging of this file. Please review the following information to
 * ensure the GNU Lesser General Public License version 3 requirements
 * will be met: https://www.gnu.org/licenses/lgpl.html.
 *
 * GNU General Public License Usage
 * Alternatively, this file may be used under the terms of the GNU
 * General Public License version 2.0 or later as published by the Free
 * Software Foundation and appearing in the file LICENSE.GPL included in
 * the packaging of this file. Please review the following information to
 * ensure the GNU General Public License version 2.0 requirements will be
 * met: http://www.gnu.org/licenses/gpl-2.0.html.
 */


import QtQuick 6.0
import Qt5Compat.GraphicalEffects 6.0
import QtQuick.Controls 6.0 as Controls
import QtQuick.Templates 6.0 as T
import "ThemeValues.js" as ThemeValues

T.ToolTip {
    id: controlRoot

    // 提示显示在按钮下方（原实现显示在上方，与菜单栏/工具栏布局冲突）
    x: parent ? (parent.width - implicitWidth) / 2 : 0
    y: parent ? parent.height + ThemeValues.smallSpacing : 0

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    margins: 6
    padding: 6

    closePolicy: T.Popup.CloseOnEscape | T.Popup.CloseOnPressOutsideParent | T.Popup.CloseOnReleaseOutsideParent

    contentItem: Controls.Label {
        text: controlRoot.text
        font: controlRoot.font
        color: ThemeValues.textColor
    }

    background: Rectangle {
        color: ThemeValues.secondBackgroundColor
        radius: ThemeValues.smallRadius

        // 原实现用 layer + DropShadow 做阴影，但软件渲染（QSG software）下
        // GraphicalEffects 无法工作，导致提示背景透明、与背景混为一体。
        // 改用带边框的实心背景，任何渲染后端都清晰可见。
        border.width: 1
        border.color: ThemeValues.darkMode ? Qt.rgba(255, 255, 255, 0.15)
                                           : Qt.rgba(0, 0, 0, 0.12)
    }
}