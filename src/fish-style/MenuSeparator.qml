import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Templates 6.0 as T

// 注意：本文件是 QtQuick.Controls 的 fish-style 主题实现。
// 禁止 `import FishUI` —— 会与 FishUI 模块的 `depends QtQuick.Controls` 形成循环依赖。
// 此处用 Qt 标准 API（palette）实现同等外观。

T.MenuSeparator {
    id: control

    implicitHeight: 12 + separator.height
    width: parent.width

    background: Rectangle {
        id: separator
        anchors.centerIn: control
        width: control.width - 24
        height: 1
        color: control.palette.text
        opacity: 0.3
    }
}