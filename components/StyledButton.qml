import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules

Control {
  id: root
  property alias text: label.text
  property string icon: ""
  property int icon_size: 20
  property int radius: 20

  property bool checkable: false
  property bool checked: true
  property bool secondary: false
  signal clicked
  signal toggled(bool checked)

  // --- state colors ---
  property bool usePrimary: secondary ? false : checked

  property color base_bg: usePrimary
    ? Appearance.colors.m3primary
    : Appearance.colors.m3secondary_container

  property color base_fg: usePrimary
    ? Appearance.colors.m3on_primary
    : Appearance.colors.m3on_secondary_container

  property color hover_bg: Qt.lighter(base_bg, 1.1)
  property color pressed_bg: Qt.darker(base_bg, 1.2)

  property color background_color: mouse_area.pressed
    ? pressed_bg
    : mouse_area.containsMouse ? hover_bg : base_bg

  property color text_color: base_fg

  // With this:
  implicitWidth: (label.text === "" && icon !== "") 
      ? implicitHeight   // square if only icon
      : row.implicitWidth + implicitHeight
  implicitHeight: 40

  contentItem: Item {
    anchors.fill: parent

    Row {
      id: row
      anchors.centerIn: parent
      spacing: root.icon !== "" && label.text !== "" ? 5 : 0

      MaterialIcon {
        visible: root.icon !== ""
        icon: root.icon
        font.pixelSize: root.icon_size
        color: root.text_color
        anchors.verticalCenter: parent.verticalCenter
        Behavior on color {
          ColorAnimation { duration: Appearance.anim_fast / 2; easing.type: Easing.OutExpo }
        }
      }

      Text {
        id: label
        font.pixelSize: 14
        color: root.text_color
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        Behavior on color {
          ColorAnimation { duration: Appearance.anim_fast / 2; easing.type: Easing.OutExpo }
        }
      }
    }
  }

  background: Rectangle {
    radius: root.radius
    color: root.background_color
    Behavior on color {
      ColorAnimation { duration: Appearance.anim_fast / 2; easing.type: Easing.OutExpo }
    }
  }

  MouseArea {
    id: mouse_area
    anchors.fill: parent
    hoverEnabled: true
    onClicked: {
      root.clicked()
      if (root.checkable) {
        root.checked = !root.checked
        root.toggled(root.checked)
      }
    }
  }
}
