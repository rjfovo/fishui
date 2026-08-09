/*
 * Copyright (C) 2021 CutefishOS Team.
 *
 * Author:     Reion Wong <reion@cutefishos.com>
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
import QtQuick.Templates 6.0 as T
import Qt5Compat.GraphicalEffects 6.0
import "ThemeValues.js" as ThemeValues
import QtQuick.Controls.impl 6.0

T.Button {
    id: control
    implicitWidth: Math.max(background.implicitWidth, contentItem.implicitWidth + ThemeValues.largeSpacing)
    implicitHeight: background.implicitHeight
    hoverEnabled: true

    icon.width: ThemeValues.iconSizes.small
    icon.height: ThemeValues.iconSizes.small

    icon.color: control.enabled ? (control.highlighted ? ThemeValues.highlightColor : ThemeValues.textColor) : ThemeValues.disabledTextColor
    spacing: ThemeValues.smallSpacing

    property color hoveredColor: ThemeValues.darkMode ? Qt.lighter(ThemeValues.alternateBackgroundColor, 1.2)
                                                       : Qt.darker(ThemeValues.alternateBackgroundColor, 1.1)

    property color pressedColor: ThemeValues.darkMode ? Qt.lighter(ThemeValues.alternateBackgroundColor, 1.1)
                                                       : Qt.darker(ThemeValues.alternateBackgroundColor, 1.2)

    property color borderColor: Qt.rgba(ThemeValues.highlightColor.r,
                                        ThemeValues.highlightColor.g,
                                        ThemeValues.highlightColor.b, 0.5)

    property color flatHoveredColor: Qt.rgba(ThemeValues.highlightColor.r,
                                             ThemeValues.highlightColor.g,
                                             ThemeValues.highlightColor.b, 0.2)
    property color flatPressedColor: Qt.rgba(ThemeValues.highlightColor.r,
                                             ThemeValues.highlightColor.g,
                                             ThemeValues.highlightColor.b, 0.25)

    contentItem: IconLabel {
        text: control.text
        font: control.font
        icon: control.icon
        color: !control.enabled ? ThemeValues.disabledTextColor : control.flat ? ThemeValues.highlightColor : ThemeValues.textColor
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignCenter
    }

    background: Item {
        implicitWidth: (ThemeValues.iconSizes.medium * 3) + ThemeValues.largeSpacing
        implicitHeight: ThemeValues.iconSizes.medium + ThemeValues.smallSpacing

        Rectangle {
            id: _flatBackground
            anchors.fill: parent
            radius: ThemeValues.mediumRadius
            border.width: 1
            border.color: control.enabled ? control.activeFocus ? ThemeValues.highlightColor : "transparent"
                                          : "transparent"
            visible: control.flat

            color: {
                if (!control.enabled)
                    return ThemeValues.alternateBackgroundColor

                if (control.pressed)
                    return control.flatPressedColor

                if (control.hovered)
                    return control.flatHoveredColor

                return Qt.rgba(ThemeValues.highlightColor.r,
                               ThemeValues.highlightColor.g,
                               ThemeValues.highlightColor.b, 0.1)
            }
        }

        Rectangle {
            id: _background
            anchors.fill: parent
            radius: ThemeValues.mediumRadius
            border.width: 1
            visible: !control.flat
            border.color: control.enabled ? control.activeFocus ? ThemeValues.highlightColor : "transparent"
                                          : "transparent"

            color: {
                if (!control.enabled)
                    return ThemeValues.alternateBackgroundColor

                if (control.pressed)
                    return control.pressedColor

                if (control.hovered)
                    return control.hoveredColor

                return ThemeValues.alternateBackgroundColor
            }
        }
    }
}
