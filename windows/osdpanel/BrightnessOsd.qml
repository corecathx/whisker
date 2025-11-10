import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules
import qs.services

Item {
    id: root
    property bool shouldShowOsd: false
    Layout.fillWidth: true
    Layout.leftMargin: 10
    Layout.rightMargin: 10
    visible: shouldShowOsd
    implicitHeight: 80

	Connections {
        target: Brightness
        function onBrightnessChanged(newValue) {
            root.shouldShowOsd = true;
			hideTimer.restart();
        }
    }
	Timer {
		id: hideTimer
		interval: 3000
		onTriggered: root.shouldShowOsd = false
	}
  Rectangle {
    id: rectang
    anchors.fill: parent
    implicitHeight:child.height
    radius: 20
    color: Appearance.colors.m3surface

    RowLayout {
      id: child
      anchors {
        fill: parent
        leftMargin: 10
        rightMargin: 10
      }
      spacing: 10

      MaterialIcon {
        icon: Brightness.icon
        font.pixelSize: 24;
        color: Appearance.colors.m3on_background
      }

      ColumnLayout {
        Layout.fillWidth: true
        implicitHeight: 40
        spacing: 5

        StyledText {
          color: Appearance.colors.m3on_background
          text: "Brightness - " + Math.round(Brightness.value * 100) + "%"
          font.pixelSize: 14
        }

        StyledSlider {
          implicitHeight: 20
          value: Brightness.value*100
          trackHeightDiff: 10
        }
      }
    }
  }
}
