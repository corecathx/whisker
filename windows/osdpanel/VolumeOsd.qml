import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire
import qs.components
import qs.modules

Item {
  id: root
  property bool shouldShowOsd: false
  Layout.fillWidth: true
  Layout.leftMargin: 10
  Layout.rightMargin: 10
  visible: shouldShowOsd
  implicitHeight: 80

	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio ?? null

		function onVolumeChanged() {
			root.shouldShowOsd = true;
			hideTimer.restart();
		}

		function onMutedChanged() {
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
        property real volume: Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume*100
                      icon: {
            return volume > 50 ? "volume_up" : volume > 0 ? "volume_down" : 'volume_off'
          }
        font.pixelSize: 24;
        color: Appearance.colors.m3on_background
      }

      ColumnLayout {
        Layout.fillWidth: true
        implicitHeight: 40
        spacing: 5

        StyledText {
          color: Appearance.colors.m3on_background
          text: Pipewire.defaultAudioSink?.description + " - " + (Pipewire.defaultAudioSink?.audio.muted ? 'Muted' : Math.floor(Pipewire.defaultAudioSink?.audio.volume*100) + '%')
          font.pixelSize: 14
        }

        StyledSlider {
          implicitHeight: 20
          trackHeightDiff: 10
          value: (Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume)*100
        }
      }
    }
  }
}
