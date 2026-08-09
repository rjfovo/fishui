// fish-style 内部共享的主题/单位常量（JS 模块）。
// 注意：不能 import FishUI（循环依赖），也不能 import 单个 .qml 文件（Qt6 不支持），
// 因此用 .js 文件提供常量。Qt6 中 `import "foo.js" as Foo` 是标准用法。
// 值为进程启动时计算（darkMode 等随启动时系统配色而定）。
.pragma library

// Qt.ColorScheme 枚举在 .js 模块中不可用（报 Cannot read property 'Dark' of undefined），
// 直接用整数值：0=Unknown, 1=Light, 2=Dark
var darkMode = Qt.styleHints.colorScheme === 2

// 颜色（与 FishUI.Theme 一致）
var textColor = darkMode ? "#FFFFFF" : "#323238"
var disabledTextColor = darkMode ? "#888888" : "#64646E"
var backgroundColor = darkMode ? "#1C1C1D" : "#F3F4F9"
var secondBackgroundColor = darkMode ? "#2C2C2D" : "#FFFFFF"
var alternateBackgroundColor = darkMode ? "#3C3C3D" : "#F2F4F5"
var highlightColor = "#0176D3"
var highlightedTextColor = "#FFFFFF"
var linkColor = "#2196F3"

// 圆角
var smallRadius = 8
var mediumRadius = 10
var bigRadius = 12
var hugeRadius = 14

// 字体
var fontFamily = "Noto Sans CJK SC"
var fontSize = 10
var defaultFont = Qt.font({ family: "Sans Serif", pointSize: 10 })
var renderType = 0   // Text.QtRendering

// 单位（与 FishUI.Units 一致）
var smallSpacing = 6
var largeSpacing = 12
var extendBorderWidth = 0
var iconSizes = { small: 16, smallMedium: 22, medium: 32, large: 48, huge: 64 }
