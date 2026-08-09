import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Templates 6.0 as T
import "ThemeValues.js" as ThemeValues

T.Frame {
    id: control

    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    padding: 6

    background: Rectangle {
        color: "transparent"
        property color borderColor: ThemeValues.textColor
        border.color: Qt.rgba(borderColor.r, borderColor.g, borderColor.b, 0.3)
    }
}
