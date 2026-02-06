import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules

import Quickshell
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
  property string tooltipText: ""
  signal clicked
  signal toggled(bool checked)

  property bool usePrimary: secondary ? false : checked
  property color base_bg: usePrimary
    ? Appearance.colors.m3primary
    : Appearance.colors.m3secondary_container
  property color base_fg: usePrimary
    ? Appearance.colors.m3on_primary
    : Appearance.colors.m3on_secondary_container

  property color disabled_bg: Appearance.colors.m3surface_container
  property color disabled_fg: Appearance.colors.m3on_surface_variant

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

  opacity: root.enabled ? 1.0 : 0.5

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
          ColorAnimation { duration: 100; easing.type: Easing.OutCubic }
        }
      }

      StyledText {
        id: label
        font.pixelSize: 14
        color: root.text_color
        anchors.verticalCenter: parent.verticalCenter
        elide: Text.ElideRight

        Behavior on color {
          ColorAnimation { duration: 100; easing.type: Easing.OutCubic }
        }
      }
    }
  }

  background: Rectangle {
    id: background
    radius: 20
    color: root.background_color

    Behavior on color {
      ColorAnimation { duration: 100; easing.type: Easing.OutCubic }
    }
    Behavior on radius {
      NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
    }
    Behavior on topLeftRadius {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
    Behavior on topRightRadius {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
    Behavior on bottomLeftRadius {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
    Behavior on bottomRightRadius {
      NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }
  }

  Behavior on opacity {
    NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
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

  HoverHandler {
    id: hover
    enabled: root.tooltipText !== ""
  }

  LazyLoader {
    active: root.tooltipText !== ""
    StyledPopout {
      hoverTarget: hover
      hoverDelay: 500
      Component {
        StyledText {
          text: root.tooltipText
        }
      }
    }
  }
}
