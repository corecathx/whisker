import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules

Control {
  id: root
  property alias text: label.text
  property string icon: ""
  property int icon_size: 20
  property alias radius: background.radius
  property alias topLeftRadius: background.topLeftRadius
  property alias topRightRadius: background.topRightRadius
  property alias bottomLeftRadius: background.bottomLeftRadius
  property alias bottomRightRadius: background.bottomRightRadius
  property bool checkable: false
  property bool checked: true
  property bool secondary: false
  signal clicked
  signal toggled(bool checked)

  property bool usePrimary: secondary ? false : checked
  property color base_bg: usePrimary
    ? Appearance.colors.m3primary
    : Appearance.colors.m3secondary_container
  property color base_fg: usePrimary
    ? Appearance.colors.m3on_primary
    : Appearance.colors.m3on_secondary_container

  property color disabled_bg: Colors.opacify(base_bg, 0.4)
  property color disabled_fg: Colors.opacify(base_fg, 0.4)

  property color hover_bg: Qt.lighter(base_bg, 1.1)
  property color pressed_bg: Qt.darker(base_bg, 1.2)

  property color background_color: !root.enabled
    ? disabled_bg
    : mouse_area.pressed
      ? pressed_bg
      : mouse_area.containsMouse ? hover_bg : base_bg

  property color text_color: !root.enabled ? disabled_fg : base_fg

  implicitWidth: (label.text === "" && icon !== "")
      ? implicitHeight
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
          ColorAnimation { duration: Appearance.animation.fast / 2; easing.type: Appearance.animation.easing }
        }
      }

      StyledText {
        id: label
        font.pixelSize: 14
        color: root.text_color
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight
        Behavior on color {
          ColorAnimation { duration: Appearance.animation.fast / 2; easing.type: Appearance.animation.easing }
        }
      }
    }
  }

  background: Rectangle {
      id: background
    radius: 20
    color: root.background_color
    Behavior on color { ColorAnimation { duration: Appearance.animation.fast / 2; easing.type: Appearance.animation.easing } }
    Behavior on radius { NumberAnimation { duration: Appearance.animation.fast / 2; easing.type: Appearance.animation.easing } }
    Behavior on topLeftRadius { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
    Behavior on topRightRadius { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
    Behavior on bottomLeftRadius { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
    Behavior on bottomRightRadius { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }

  }

  MouseArea {
    id: mouse_area
    anchors.fill: parent
    hoverEnabled: root.enabled
    cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ForbiddenCursor
    onClicked: {
      if (!root.enabled) return

      if (root.checkable) {
        root.checked = !root.checked
        root.toggled(root.checked)
      }
      root.clicked()
    }
  }
}
