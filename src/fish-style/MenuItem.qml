import QtQuick 6.0
import QtQuick.Templates 6.0 as T
import QtQuick.Controls 6.0

// 注意：本文件是 QtQuick.Controls 的 fish-style 主题实现（由 QT_QUICK_CONTROLS_STYLE=FishUI 激活）。
// 禁止 `import FishUI` —— FishUI 模块 qmldir 声明了 `depends QtQuick.Controls`，
// 主题文件再 import FishUI 会形成“QtQuick.Controls(fish-style) → FishUI → QtQuick.Controls”循环依赖，
// 导致 FishUI.MenuItem 等类型解析失败（桌面图标层 Main.qml 因此编译失败、整屏黑）。
// 此处改用 Qt 标准 API（palette / styleHints / 常量）实现同等外观。
//
// 与 FishUI.DesktopMenu/FishUI.MenuItem 保持同一套设计语言：
// 行高 30px、圆角胶囊高亮（上下内缩 2px）、文字 14px 垂直居中、
// 勾选标记主题色、子菜单箭头右对齐。

T.MenuItem
{
    id: control

    readonly property bool isDark: Qt.styleHints.colorScheme === Qt.ColorScheme.Dark

    // 文字颜色使用硬编码（与 ThemeValues.textColor/disabledTextColor 一致）：
    // 菜单由独立的 PopupWindow 承载，其 palette 可能未正确初始化。
    readonly property color textColor: isDark ? "#F2F3F5" : "#313136"
    readonly property color disabledTextColor: isDark ? "#7A7A84" : "#A6A6B0"
    readonly property color accentColor: isDark ? "#7FC2FF" : "#0176D3"

    property color hoveredColor: isDark ? Qt.rgba(255, 255, 255, 0.08)
                                        : Qt.rgba(0, 0, 0, 0.06)
    property color highlightedColor: isDark ? Qt.rgba(255, 255, 255, 0.12)
                                            : Qt.rgba(0, 0, 0, 0.08)
    property color pressedColor: isDark ? Qt.rgba(255, 255, 255, 0.16)
                                        : Qt.rgba(0, 0, 0, 0.12)

    implicitWidth: {
        var w = 0
        if (control.checkable)
            w += 18
        if (control.icon && control.icon.source)
            w += 16 + 8
        w += textMetrics.advanceWidth
        if (control.subMenu)
            w += 14
        return Math.max(150, w) + control.leftPadding + control.rightPadding
    }

    implicitHeight: 30

    TextMetrics {
        id: textMetrics
        text: control.text
        font: control.font
    }

    padding: 0
    leftPadding: 8
    rightPadding: 8
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true

    // 圆角胶囊高亮背景（上下内缩 2px，左右由菜单内边距留白）
    background: Rectangle {
        radius: 7
        color: control.pressed ? control.pressedColor
               : control.highlighted ? control.highlightedColor
               : control.hovered ? control.hoveredColor
               : "transparent"

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 2
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
    }

    // 内容：勾选标记 + 图标 + 文字
    contentItem: Item {
        Image {
            id: menuIcon
            width: 16
            height: 16
            visible: control.icon && control.icon.source ? control.icon.source.toString().length > 0 : false
            source: control.icon && control.icon.source ? control.icon.source : ""
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
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

    // 子菜单箭头：右对齐，垂直居中
    arrow: Text {
        visible: control.subMenu
        text: "\u203A"
        color: control.enabled ? control.textColor : control.disabledTextColor
        opacity: 0.7
        font.pixelSize: 16
        x: control.width - control.rightPadding - width - 2
        y: (control.height - height) / 2
    }
}

