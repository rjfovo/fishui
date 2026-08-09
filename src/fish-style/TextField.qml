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
import QtQuick.Window 6.0
import QtQuick.Controls 6.0 as Controls
import QtQuick.Templates 6.0 as T
import "ThemeValues.js" as ThemeValues

T.TextField {
    id: control

    implicitWidth: Math.max(200,
                            placeholderText ? placeholder.implicitWidth + leftPadding + rightPadding : 0)
                            || contentWidth + leftPadding + rightPadding + ThemeValues.extendBorderWidth
    implicitHeight: Math.max(contentHeight + topPadding + bottomPadding,
                             background ? background.implicitHeight : 0,
                             placeholder.implicitHeight + topPadding + bottomPadding + ThemeValues.extendBorderWidth)

    // padding: 6
    leftPadding: ThemeValues.smallSpacing + ThemeValues.extendBorderWidth
    rightPadding: ThemeValues.smallSpacing + ThemeValues.extendBorderWidth

    //Text.NativeRendering is broken on non integer pixel ratios
    // renderType: Window.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering
    renderType: ThemeValues.renderType

    color: control.enabled ? ThemeValues.textColor : ThemeValues.disabledTextColor
    selectionColor: ThemeValues.highlightColor
    selectedTextColor: ThemeValues.highlightedTextColor
    selectByMouse: true

    horizontalAlignment: Text.AlignLeft
    verticalAlignment: TextInput.AlignVCenter

    opacity: control.enabled ? 1.0 : 0.5

 	// cursorDelegate: CursorDelegate { }

    Controls.Label {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)

        text: control.placeholderText
        font: control.font
        color: ThemeValues.textColor
        opacity: 0.4
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: control.verticalAlignment
        visible: !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
	}

    background: Rectangle {
        implicitWidth: (ThemeValues.iconSizes.medium * 3) + ThemeValues.smallSpacing + ThemeValues.extendBorderWidth
        implicitHeight: ThemeValues.iconSizes.medium + ThemeValues.smallSpacing + ThemeValues.extendBorderWidth
        // color: control.activeFocus ? Qt.lighter(ThemeValues.backgroundColor, 1.4) : ThemeValues.backgroundColor
        color: ThemeValues.alternateBackgroundColor
        radius: ThemeValues.smallRadius

        border.width: 1
        border.color: control.activeFocus ? ThemeValues.highlightColor : ThemeValues.alternateBackgroundColor

        // Rectangle {
        //     id: _border
        //     anchors.fill: parent
        //     color: "transparent"
        //     border.color: control.activeFocus ? Qt.rgba(ThemeValues.highlightColor.r,
        //                                                 ThemeValues.highlightColor.g,
        //                                                 ThemeValues.highlightColor.b, 0.2) : "transparent"
        //     border.width: ThemeValues.extendBorderWidth
        //     radius: ThemeValues.smallRadius + ThemeValues.extendBorderWidth

        //     Behavior on border.color {
        //         ColorAnimation {
        //             duration: 50
        //         }
        //     }
        // }

        // Rectangle {
        //     anchors.fill: parent
        //     anchors.margins: ThemeValues.extendBorderWidth
        //     radius: ThemeValues.smallRadius
        //     color: ThemeValues.backgroundColor
        //     border.color: control.activeFocus ? ThemeValues.highlightColor : Qt.tint(ThemeValues.textColor, Qt.rgba(ThemeValues.backgroundColor.r, ThemeValues.backgroundColor.g, ThemeValues.backgroundColor.b, 0.7))
        //     border.width: 1
        // }
    }
}
