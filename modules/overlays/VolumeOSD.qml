import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.modules
import qs.components
import qs.preferences

Scope {
	id: root

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


	property bool shouldShowOsd: false

	Timer {
		id: hideTimer
		interval: 3000
		onTriggered: root.shouldShowOsd = false
	}

	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			anchors.top: Preferences.bar.position === 'top'
			margins.top: Preferences.bar.position === 'top' ? 10 : 0

            anchors.bottom: Preferences.bar.position === 'bottom'
			margins.bottom: Preferences.bar.position === 'bottom' ? 10 : 0

			anchors.right: true
			margins.right: Preferences.bar.small ? Preferences.bar.padding + 10 : 10


			implicitWidth: 400
			implicitHeight: 70
			color: 'transparent'

			mask: Region {}

			Rectangle {
				anchors.fill: parent
				radius: 20
				color: Appearance.panel_color


				RowLayout {
					spacing: 10
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 15
					}

					MaterialIcon {
						property real volume: Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume*100
													icon: {
								return volume > 50 ? "volume_up" : volume > 0 ? "volume_down" : 'volume_off'
							}
						font.pixelSize: 30;
						color: Appearance.colors.m3on_background
					}

					ColumnLayout {
						Layout.fillWidth: true
						implicitHeight: 40
						spacing: 5

						StyledText {
							color: Appearance.colors.m3on_background
							text: Pipewire.defaultAudioSink?.description + " - " + (Pipewire.defaultAudioSink?.audio.muted ? 'Muted' : Math.floor(Pipewire.defaultAudioSink?.audio.volume*100) + '%')
							font.pixelSize: 16
						}

						StyledSlider {
							implicitHeight: 20
							icon: ""
							value: (Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume)*100
						}
					}
				}
			}
		}
	}
}
