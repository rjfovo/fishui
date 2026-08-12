import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Templates 6.0 as T
import QtQuick.Window 6.0
import Qt5Compat.GraphicalEffects 6.0

// 注意：本文件是 QtQuick.Controls 的 fish-style 主题实现。
// 禁止 `import FishUI` —— 会与 FishUI 模块的 `depends QtQuick.Controls` 形成循环依赖，
// 导致类型解析失败。此处用 Qt 标准 API（palette / styleHints / 常量）实现同等外观。

T.Menu
{
    id: control

    readonly property bool isDark: Qt.styleHints.colorScheme === Qt.ColorScheme.Dark
    readonly property color menuBackgroundColor: isDark ? "#1E1E20" : "#FFFFFF"

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    margins: 0
    padding: 6
    verticalPadding: 6
    spacing: 0
    transformOrigin: !cascade ? Item.Top : (mirrored ? Item.TopRight : Item.TopLeft)

    delegate: MenuItem { }

    enter: Transition {
        NumberAnimation {
            property: "opacity"
            from: 0
            to: 1
            easing.type: Easing.InOutCubic
            duration: 100
        }
    }

    exit: Transition {
        NumberAnimation {
            property: "opacity"
            from: 1
            to: 0
            easing.type: Easing.InOutCubic
            duration: 200
        }
    }

    contentItem: ListView {
        id: menuListView
        implicitHeight: contentHeight

        implicitWidth: {
            var maxWidth = 0;
            for (var i = 0; i < contentItem.children.length; ++i) {
                maxWidth = Math.max(maxWidth, contentItem.children[i].implicitWidth);
            }
            return maxWidth;
        }

        model: control.contentModel
        interactive: Window.window ? contentHeight > Window.window.height : false
        clip: false
        currentIndex: control.currentIndex || 0
        spacing: control.spacing
        keyNavigationEnabled: true
        keyNavigationWraps: true

        // 内容按菜单圆角裁剪（避免首/末项高亮超出圆角）。
        // 软件渲染（QSG software）下 layer + OpacityMask 不工作，会导致菜单项
        // 内容不渲染（菜单空白），因此这里禁用 layer（背景本身已带圆角）。
        layer.enabled: false
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                radius: 10
                width: menuListView.width
                height: menuListView.height
            }
        }

        ScrollBar.vertical: ScrollBar {}
    }

    background: Rectangle {
        // 原实现用 layer + DropShadow 做阴影，但软件渲染（QSG software）下
        // GraphicalEffects 无法工作，导致菜单背景整体不渲染（菜单"看不见"）。
        // 改用简单边框，任何渲染后端都稳定可见。
        radius: 10
        color: control.menuBackgroundColor
        antialiasing: true

        border.width: 1
        border.color: control.isDark ? Qt.rgba(255, 255, 255, 0.15) : Qt.rgba(0, 0, 0, 0.12)
    }

    T.Overlay.modal: Rectangle  {
        color: Qt.rgba(control.menuBackgroundColor.r,
                       control.menuBackgroundColor.g,
                       control.menuBackgroundColor.b, 0.4)
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutCubic
            }
        }
    }

    T.Overlay.modeless: Rectangle {
        color: Qt.rgba(control.menuBackgroundColor.r,
                       control.menuBackgroundColor.g,
                       control.menuBackgroundColor.b, 0.4)
        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutCubic
            }
        }
    }
}

