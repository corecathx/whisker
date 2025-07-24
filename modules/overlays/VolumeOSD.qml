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
		target: Pipewire.defaultAudioSink?.audio

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
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}

	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			anchors.top: ShellLayout.bar_position === 'top'
			margins.top: ShellLayout.bar_position === 'top' ? 10 : 0

            anchors.bottom: ShellLayout.bar_position === 'bottom'
			margins.bottom: ShellLayout.bar_position === 'bottom' ? 10 : 0
			
			anchors.right: true
			margins.right: 10

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

					MaterialSymbol {
						property real volume: Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume*100
						icon: volume > 50 ? "volume_up" : volume > 0 ? "volume_down" : 'volume_off' 
						font.pixelSize: 30;
						color: Colors.foreground
					}

					ColumnLayout {
						Layout.fillWidth: true
						implicitHeight: 20
						spacing: 5
						
						Text {
							color: Colors.foreground
							text: Pipewire.defaultAudioSink?.description + " - " + (Pipewire.defaultAudioSink?.audio.muted ? 'Muted' : Math.floor(Pipewire.defaultAudioSink?.audio.volume*100) + '%')
							font.pixelSize: 16
						}
						
						Rectangle {
							Layout.fillWidth: true
							height: 20
							color: 'transparent'
							
							Rectangle {
								id: backgroundBar
								width: parent.width
								height: 10
								radius: 20
								color: Colors.opacify(Colors.darken(Colors.foreground, 0.5), 0.4)
								
								Rectangle {
									property real volume: Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume

									id: volumeBar
									anchors.verticalCenter: parent.verticalCenter
									width: parent.width * (volume || 0)
									height: parent.height+10
									radius: parent.radius
									color: Colors.foreground

									Behavior on width {
										NumberAnimation {
											duration: 100
											easing: Easing.OutQuad
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
}
