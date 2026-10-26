import QtQuick

StyledText {
  id: root
  property bool filled: false
  property real fill: filled ? 1 : 0
  property int grad: 0
  required property string icon
  property int size: 24

  font.pixelSize: root.size
  font.family: "Material Symbols Rounded"
  font.hintingPreference: Font.PreferFullHinting
  antialiasing: true
  font.variableAxes: {
    "FILL": root.fill,
    "opsz": root.fontInfo.pixelSize,
    "GRAD": root.grad,
    "wght": root.fontInfo.weight
  }
  renderType: fill != 0 ? Text.NativeRendering : Text.QtRendering

  text: root.icon
}
