import QtQuick 6.0
import QtQuick.Templates 6.0 as T
import QtQuick.Controls 6.0
import QtQuick.Controls.impl 6.0

// 注意：本文件是 QtQuick.Controls 的 fish-style 主题实现（由 QT_QUICK_CONTROLS_STYLE=FishUI 激活）。
// 禁止 `import FishUI` —— FishUI 模块 qmldir 声明了 `depends QtQuick.Controls`，
// 主题文件再 import FishUI 会形成“QtQuick.Controls(fish-style) → FishUI → QtQuick.Controls”循环依赖，
// 导致 FishUI.MenuItem 等类型解析失败（桌面图标层 Main.qml 因此编译失败、整屏黑）。
// 此处改用 Qt 标准 API（palette / styleHints / 常量）实现同等外观。

T.MenuItem
{
    id: control

    FontMetrics {
        id: fm
    }

    readonly property bool isDark: Qt.styleHints.colorScheme === Qt.ColorScheme.Dark

    // 文字颜色使用硬编码（与 FishUI.Theme.textColor/disabledTextColor 一致）：
    // 菜单由独立的 MenuPopupWindow(QQuickWindow) 承载，其 palette 可能未正确初始化
    // （palette.text 不可见，导致菜单项文字不显示），不能依赖 palette。
    readonly property color textColor: isDark ? "#FFFFFF" : "#323238"
    readonly property color disabledTextColor: isDark ? "#888888" : "#64646E"

    property color hoveredColor: isDark ? Qt.rgba(255, 255, 255, 0.2)
                                        : Qt.rgba(0, 0, 0, 0.1)
    property color pressedColor: isDark ? Qt.rgba(255, 255, 255, 0.1)
                                        : Qt.rgba(0, 0, 0, 0.2)

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    verticalPadding: 6
    hoverEnabled: true
    topPadding: 6
    bottomPadding: 6

    icon.width: 32
    icon.height: 32

    icon.color: control.enabled ? (control.highlighted ? control.palette.highlight : control.textColor) :
                             control.disabledTextColor

    // 内容：图标 + 文字 + 子菜单箭头
    // 注意：不能使用 QtQuick.Controls.impl 的 IconLabel —— 在软件渲染后端
    // （QT_QUICK_BACKEND=software）下其文字（QQuickIconLabel）不渲染（菜单显示为空白），
    // 改用纯 QML 元素（Image/Text），软件渲染后端绘制正常。
    contentItem: Row {
        readonly property real arrowPadding: control.subMenu && control.arrow ? 12 : 0
        readonly property real indicatorPadding: control.checkable && control.indicator ? 12 : 0

        anchors.left: parent.left
        anchors.leftMargin: indicatorPadding + 6
        anchors.right: parent.right
        anchors.rightMargin: arrowPadding + 6

        spacing: 6
        layoutDirection: control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Image {
            width: 16
            height: 16
            anchors.verticalCenter: parent.verticalCenter
            source: control.icon && control.icon.source ? control.icon.source : ""
            visible: control.icon && control.icon.source.toString().length > 0
        }

        Canvas {
            id: menuTextCanvas
            width: 150
            height: 18
            anchors.verticalCenter: parent.verticalCenter

            property string label: control.text
            property color textColor: control.enabled ? control.textColor : control.disabledTextColor

            onLabelChanged: requestPaint()
            onTextColorChanged: requestPaint()

            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                ctx.fillStyle = textColor
                ctx.font = "14px sans-serif"
                ctx.textBaseline = "middle"
                ctx.textAlign = "left"
                ctx.fillText(label, 0, height / 2)
            }
        }

        Item { width: 1; height: 1; visible: false }

        Text {
            visible: control.subMenu
            text: "\u203A"
            font.pointSize: 10
            color: control.enabled ? control.textColor : control.disabledTextColor
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    background: Rectangle {
        implicitWidth: 200
        implicitHeight: control.visible ? fm.height + 12 : 0
        // 与菜单背景（hugeRadius）保持一致，避免首/末项高亮出现直角角
        radius: 14
        opacity: 1

        anchors {
            fill: parent
            leftMargin: 6
            rightMargin: 6
        }

        color: control.pressed || highlighted ? control.pressedColor : control.hovered ? control.hoveredColor : "transparent"
    }
}
