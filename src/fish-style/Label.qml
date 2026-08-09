import QtQuick 6.0
import QtQuick.Window 6.0
import QtQuick.Templates 6.0 as T
import "ThemeValues.js" as ThemeValues

T.Label {
    id: control

    verticalAlignment: lineCount > 1 ? Text.AlignTop : Text.AlignVCenter

    activeFocusOnTab: false
    // Text.NativeRendering is broken on non integer pixel ratios
    // renderType: Window.devicePixelRatio % 1 !== 0 ? Text.QtRendering : Text.NativeRendering

    renderType: ThemeValues.renderType

    font.capitalization: ThemeValues.defaultFont.capitalization
    font.family: ThemeValues.fontFamily
    font.italic: ThemeValues.defaultFont.italic
    font.letterSpacing: ThemeValues.defaultFont.letterSpacing
    font.pointSize: ThemeValues.fontSize
    font.strikeout: ThemeValues.defaultFont.strikeout
    font.underline: ThemeValues.defaultFont.underline
    font.weight: ThemeValues.defaultFont.weight
    font.wordSpacing: ThemeValues.defaultFont.wordSpacing
    color: ThemeValues.textColor
    linkColor: ThemeValues.linkColor

    opacity: enabled ? 1 : 0.6

    Accessible.role: Accessible.StaticText
    Accessible.name: text
}
