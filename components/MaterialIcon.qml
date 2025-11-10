import QtQuick

StyledText {
  id: root
  property real fill: 0
  property int grad: 0
  required property string icon

  font.family: "Material Symbols Rounded"
  font.hintingPreference: Font.PreferFullHinting
  font.variableAxes: {
    "FILL": root.fill,
    "opsz": root.fontInfo.pixelSize,
    "GRAD": root.grad,
    "wght": root.fontInfo.weight
  }
  renderType: Text.QtRendering

  text: root.icon
}
