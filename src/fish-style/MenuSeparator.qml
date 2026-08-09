import QtQuick 6.0
import QtQuick.Controls 6.0
import QtQuick.Templates 6.0 as T

// 注意：本文件是 QtQuick.Controls 的 fish-style 主题实现。
// 禁止 `import FishUI` —— 会与 FishUI 模块的 `depends QtQuick.Controls` 形成循环依赖。
// 分隔线：高 9px（上下各 4px 呼吸空间），1px 细线，水平方向内缩 12px，颜色用文字色 15% 透明度。

T.MenuSeparator {
    id: control

    // 宽度由所在布局（ColumnLayout/ListView）拉伸决定，这里只负责行高
    implicitHeight: 9
    width: parent.width

    background: Rectangle {
        id: separator
        anchors.centerIn: control
        width: control.width - 24
        height: 1
        color: control.palette.text
        opacity: 0.15
    }
}
