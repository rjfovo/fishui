import QtQuick 6.0
import QtQuick.Templates 6.0 as T
import "ThemeValues.js" as ThemeValues

T.TabButton {
    id: control

    property int standardHeight: ThemeValues.iconSizes.medium + ThemeValues.smallSpacing
    property color pressedColor: Qt.rgba(ThemeValues.textColor.r, ThemeValues.textColor.g, ThemeValues.textColor.b, 0.5)

    implicitWidth: Math.max(background ? background.implicitWidth : 0,
                            contentItem.implicitWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(background ? background.implicitHeight : 0,
                             standardHeight)
    baselineOffset: contentItem.y + contentItem.baselineOffset

    padding: 0
    spacing: 0

    contentItem: Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        text: control.text
        font: control.font
        color: !control.enabled ? ThemeValues.disabledTextColor : control.pressed ? pressedColor : control.checked ? ThemeValues.textColor : ThemeValues.textColor
    }
}
