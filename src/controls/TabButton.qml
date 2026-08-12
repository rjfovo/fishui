import QtQuick 6.0
import QtQml 6.0
import QtQuick.Window 6.0
import QtQuick.Controls 6.0
import QtQuick.Layouts 6.0
import Qt5Compat.GraphicalEffects 6.0
import FishUI 1.0 as FishUI

Item {
    id: control

    property bool checked: false
    property bool hovered: _mouseArea.containsMouse
    property bool pressed: _mouseArea.pressed

    property alias font: _label.font
    property string text: ""
    // 标签图标（可选）
    property string iconSource: ""
    // 图标着色（transparent = 不着色，保持原色）
    property color iconColor: "transparent"

    property var contentWidth: _contentLayout.implicitWidth + FishUI.Units.largeSpacing * 2

    property var backgroundColor: FishUI.Theme.secondBackgroundColor
    property var hoveredColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.secondBackgroundColor, 1.3)
                                                     : Qt.darker(FishUI.Theme.secondBackgroundColor, 1.05)
    property var pressedColor: FishUI.Theme.darkMode ? Qt.lighter(FishUI.Theme.secondBackgroundColor, 1.1)
                                                     : Qt.darker(FishUI.Theme.secondBackgroundColor, 1.1)

    property var highlightColor: FishUI.Theme.highlightColor
    property var highlightHoveredColor: Qt.lighter(control.highlightColor, 1.1)
    property var highlightPressedColor: Qt.darker(control.highlightColor, 1.1)

    property alias background: hoveredRect

    signal clicked()
    signal closeClicked()

    MouseArea {
        id: _mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }

    Rectangle {
        id: hoveredRect
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing / 2
        anchors.rightMargin: FishUI.Units.smallSpacing / 2
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        color: control.hovered ? control.pressed ? pressedColor
                                                 : hoveredColor : backgroundColor
        opacity: 0.5
        border.width: 0
        radius: FishUI.Theme.smallRadius
    }

    Rectangle {
        id: checkedRect
        anchors.leftMargin: FishUI.Units.smallSpacing / 2
        anchors.rightMargin: FishUI.Units.smallSpacing / 2
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        anchors.fill: parent

        color: control.hovered ? control.pressed ? highlightPressedColor
                                                 : highlightHoveredColor : highlightColor

        opacity: _mouseArea.pressed ? 0.9 : 1
        visible: checked
        radius: FishUI.Theme.smallRadius

        // 选中标签加线框，避免与背景混为一体
        border.width: 1
        border.color: FishUI.Theme.darkMode ? Qt.rgba(255, 255, 255, 0.5)
                                            : Qt.rgba(0, 0, 0, 0.45)
    }

    RowLayout {
        id: _contentLayout
        anchors.fill: parent
        anchors.leftMargin: FishUI.Units.smallSpacing
        anchors.rightMargin: FishUI.Units.smallSpacing
        anchors.topMargin: FishUI.Units.smallSpacing / 2
        spacing: 0

        // 标签图标（文本文件，未保存时显示红色"文档+笔"图标）
        Item {
            id: _tabIcon
            Layout.preferredWidth: 14
            Layout.preferredHeight: 14
            Layout.alignment: Qt.AlignVCenter
            visible: control.iconSource.length > 0

            Image {
                anchors.fill: parent
                source: control.iconSource
                sourceSize: Qt.size(14, 14)
                // 未选中标签图标保持较高可见度，避免红色笔与灰色笔难以区分
                opacity: control.checked ? 1 : 0.85
            }

            // 未保存时图标着色为红色
            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: control.iconColor.a > 0 ? control.iconColor : "transparent"
                visible: control.iconColor.a > 0
                cached: true
            }
        }

        Label {
            id: _label
            text: control.text
            leftPadding: 0
            rightPadding: 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            color: control.checked ? FishUI.Theme.highlightedTextColor
                                   : FishUI.Theme.textColor
            elide: Text.ElideMiddle
            wrapMode: Text.NoWrap
        }

        FishUI.TabCloseButton {
            id: _closeButton
            Layout.preferredHeight: 24
            Layout.preferredWidth: 24
            size: 24
            // 未选中标签也显示关闭按钮：平时深灰❌，hover 时红色圆底 + 白色❌
            source: FishUI.Theme.darkMode ? "qrc:/images/dark/close.svg"
                                          : "qrc:/images/light/close.svg"
            hoveredSource: "qrc:/images/dark/close.svg"
            onClicked: control.closeClicked()
        }
    }
}
