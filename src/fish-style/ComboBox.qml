/****************************************************************************
**
** Copyright (C) 2017 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the Qt Quick Controls 2 module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL3$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and The Qt Company. For licensing terms
** and conditions see http://www.qt.io/terms-conditions. For further
** information use the contact form at http://www.qt.io/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 3 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPLv3 included in the
** packaging of this file. Please review the following information to
** ensure the GNU Lesser General Public License version 3 requirements
** will be met: https://www.gnu.org/licenses/lgpl.html.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 2.0 or later as published by the Free
** Software Foundation and appearing in the file LICENSE.GPL included in
** the packaging of this file. Please review the following information to
** ensure the GNU General Public License version 2.0 requirements will be
** met: http://www.gnu.org/licenses/gpl-2.0.html.
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 6.0
import QtQuick.Window 6.0
import QtQuick.Controls 6.0
import QtQuick.Controls.impl 6.0
import QtQuick.Templates 6.0 as T
import Qt5Compat.GraphicalEffects 6.0
import "ThemeValues.js" as ThemeValues

T.ComboBox {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    topInset: 2
    bottomInset: 2

    spacing: ThemeValues.smallSpacing
    padding: ThemeValues.smallSpacing
    leftPadding: ThemeValues.largeSpacing
    rightPadding: ThemeValues.largeSpacing

    property bool darkMode: ThemeValues.darkMode

    onDarkModeChanged: {
        updateTimer.restart()
    }

    delegate: MenuItem {
        width: control.popup.width
        // 显式高度, 避免 popup 打开时 delegate 高度塌陷导致选项重叠/缩在一起
        implicitHeight: 30
        height: 30
        text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
        highlighted: control.highlightedIndex === index
        hoverEnabled: control.hoverEnabled
    }

    indicator: Image {
        id: indicatorImage
        x: control.mirrored ? control.leftPadding : control.width - width - control.rightPadding
        y: control.topPadding + (control.availableHeight - height) / 2

        height: ThemeValues.iconSizes.small
        width: height

        cache: false

        source: "image://icontheme/go-down"
        sourceSize.width: width
        sourceSize.height: height
    }

    Timer {
        id: updateTimer
        triggeredOnStart: true
        interval: 10

        onTriggered: {
            indicatorImage.source = ""
            indicatorImage.source = "image://icontheme/go-down"
        }
    }

    contentItem: T.TextField {
        padding: ThemeValues.smallSpacing
        leftPadding: 0
        rightPadding: ThemeValues.smallSpacing

        text: control.editable ? control.editText : control.displayText

        enabled: control.editable
        autoScroll: control.editable
        readOnly: control.down
        // 只读显示用，不捕获鼠标点击（否则点击被 TextField 吞掉，
        // ComboBox 收不到 TapHandler 事件，下拉列表打不开）
        activeFocusOnPress: false
        cursorVisible: false
        inputMethodHints: control.inputMethodHints
        validator: control.validator

        font: control.font
        color: control.enabled ? ThemeValues.textColor : ThemeValues.highlightColor
        selectionColor:  ThemeValues.highlightColor
        selectedTextColor: ThemeValues.highlightedTextColor
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        implicitWidth:  (ThemeValues.iconSizes.medium * 3) + ThemeValues.largeSpacing
        implicitHeight: ThemeValues.iconSizes.smallMedium + ThemeValues.smallSpacing

        radius: ThemeValues.smallRadius
        color: ThemeValues.alternateBackgroundColor

        border.color: control.activeFocus ? ThemeValues.highlightColor : color
        border.width: 1
    }

    popup: T.Popup {
        width: Math.max(control.width, 150)
        implicitHeight: Math.min(contentItem.implicitHeight, control.Window.height - topMargin - bottomMargin) + ThemeValues.largeSpacing
        transformOrigin: Item.Top

        enter: Transition {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                easing.type: Easing.InOutCubic
                duration: 150
            }
        }

        exit: Transition {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                easing.type: Easing.InOutCubic
                duration: 150
            }
        }

        contentItem: ListView {
            clip: true
            // 显式兜底: contentHeight 在 popup 首次打开时可能为 0(delegate 未实例化),
            // 导致下拉高度塌陷、选项全部挤在一起。用 count 估算兜底。
            implicitHeight: Math.max(contentHeight,
                                     control.count * (30 + ThemeValues.smallSpacing))
            model: control.delegateModel
            currentIndex: control.highlightedIndex
            highlightMoveDuration: 0
            topMargin: ThemeValues.smallSpacing
            bottomMargin: ThemeValues.smallSpacing
            spacing: ThemeValues.smallSpacing

            T.ScrollBar.vertical: ScrollBar {}
        }

        background: Rectangle {
            radius: ThemeValues.smallRadius
            // 注意：不能写成 parent.ThemeValues.secondBackgroundColor ——
            // parent 是 popup(T.Popup)，没有 ThemeValues 属性，会抛 TypeError
            // 导致 ComboBox 下拉框背景无法创建（控件回退异常）。直接引用 JS 模块即可。
            color: ThemeValues.secondBackgroundColor
            border.width: 1
            border.color: ThemeValues.darkMode ? Qt.rgba(255, 255, 255, 0.12)
                                               : Qt.rgba(0, 0, 0, 0.1)

            // 原实现用 layer + DropShadow 做阴影，但软件渲染（QSG software）下
            // GraphicalEffects 无法工作，导致下拉列表背景整体不渲染（列表"看不见"）。
            // 改用简单边框（同 Menu/Dialog/ToolTip 修复），任何渲染后端都稳定可见。
            layer.enabled: false
            layer.effect: DropShadow {
                transparentBorder: true
                radius: 32
                samples: 32
                horizontalOffset: 0
                verticalOffset: 0
                color: Qt.rgba(0, 0, 0, 0.15)
            }
        }
    }
}
