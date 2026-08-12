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
import QtQuick.Controls 6.0
import QtQuick.Controls.impl 6.0

import "ThemeValues.js" as ThemeValues

Rectangle {
    id: indicatorItem
    implicitWidth: 18
    implicitHeight: 18

    color: !control.enabled ? ThemeValues.secondBackgroundColor
                            : checked ? ThemeValues.highlightColor : ThemeValues.secondBackgroundColor
    border.color: !control.enabled ? ThemeValues.disabledTextColor
        : checked ? ThemeValues.highlightColor: ThemeValues.textColor
    border.width: 1
    radius: control.autoExclusive ? Math.min(height, width) : 4

    property Item control
    property bool checked : control.checked

    Behavior on border.width {
        NumberAnimation {
            duration: 100
            easing.type: Easing.InOutCubic
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: 100
            easing.type: Easing.InOutCubic
        }
    }   

    // 勾选标记：直接渲染文本 ✓（不依赖 qrc 资源）。
    // 原实现引用 Qt5 资源 qrc:/qt-project.org/imports/QtQuick/Controls.2/Material/images/check.png，
    // Qt6 下该 qrc 路径已失效（Controls.2 → Controls），导致勾选图标加载失败（QML QQuickImage:
    // Cannot open）。改用文本字符，与 FishUI.MenuItem 的 checkMark 保持一致。
    Text {
        id: checkImage
        anchors.centerIn: parent
        text: "\u2713"
        color: "white"
        font.pixelSize: parent.height * 0.8
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        // 微调：字符视觉中心略偏上，用基线偏移修正
        anchors.verticalCenterOffset: 1

        scale: checked ? 1 : 0
        Behavior on scale {
            NumberAnimation {
                duration: 100
                easing.type: Easing.InOutCubic
            }
        }
    }

    transitions: Transition {
        SequentialAnimation {
            NumberAnimation {
                target: indicatorItem
                property: "scale"
                // Go down 2 pixels in size.
                to: 1 - 2 / indicatorItem.width
                duration: 120
            }
            NumberAnimation {
                target: indicatorItem
                property: "scale"
                to: 1
                duration: 120
            }
        }
    }
}
