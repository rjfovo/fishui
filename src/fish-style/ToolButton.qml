/* 工具栏图标按钮（fish-style）。
 * 与 Button 保持一致的设计语言：图标 + hover/pressed 圆角高亮。
 * 之前 fish-style 缺少 ToolButton.qml，QQC2 ToolButton 回退到基础样式，
 * 导致工具栏按钮宽大、分散（"demo" 感）。
 */
import QtQuick 6.0
import QtQuick.Templates 6.0 as T
import QtQuick.Controls.impl 6.0
import "ThemeValues.js" as ThemeValues

T.ToolButton {
    id: control

    // 固定紧凑尺寸。用固定值而非 Math.max(background, contentItem)：
    // 布局时 background/contentItem 可能尚未就绪导致 implicitWidth 求值为 0，
    // 使布局容器把按钮重叠/错位排列。
    implicitWidth: 26
    implicitHeight: 26

    padding: 0
    hoverEnabled: true

    icon.width: ThemeValues.iconSizes.small
    icon.height: ThemeValues.iconSizes.small
    icon.color: control.enabled ? ThemeValues.textColor : ThemeValues.disabledTextColor
    spacing: ThemeValues.smallSpacing

    contentItem: IconLabel {
        text: control.text
        font: control.font
        icon: control.icon
        color: !control.enabled ? ThemeValues.disabledTextColor : ThemeValues.textColor
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display
        alignment: Qt.AlignCenter
    }

    background: Rectangle {
        // 紧凑尺寸：26x26 按钮 + 16px 图标（与顶部菜单栏协调）
        implicitWidth: 26
        implicitHeight: 26
        radius: ThemeValues.smallRadius

        color: {
            if (!control.enabled)
                return "transparent"
            if (control.pressed)
                return ThemeValues.darkMode ? Qt.rgba(255, 255, 255, 0.16) : Qt.rgba(0, 0, 0, 0.12)
            if (control.hovered)
                return ThemeValues.darkMode ? Qt.rgba(255, 255, 255, 0.08) : Qt.rgba(0, 0, 0, 0.06)
            return "transparent"
        }
    }
}