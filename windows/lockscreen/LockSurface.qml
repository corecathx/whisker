import QtQuick
import QtQuick.Shapes
import QtQuick.Effects
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Widgets
import qs.modules
import qs.modules.bar
import qs.components
import qs.services
import qs.preferences
import qs.modules.corners

WlSessionLockSurface {
    id: root
    required property LockContext context
	required property real animation_time
	property var easingType: Easing.OutCubic
    color: 'transparent'
    property bool startAnim: false

    ScreencopyView {
        id: background
        anchors.fill: parent
        captureSource: root.screen
        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
        	blur: root.startAnim ? 1 : 0

            blurMax: 64
            blurMultiplier: 1

			Behavior on blur {
				NumberAnimation { duration: animation_time; easing.type: easingType }
			}
        }
		scale: root.startAnim ? 1.05 : 1
		Behavior on scale {
			NumberAnimation { duration: animation_time; easing.type: easingType }
		}
		rotation: root.startAnim ? 0.5 : 0
		Behavior on rotation {
			NumberAnimation { duration: animation_time; easing.type: easingType }
		}
		Rectangle {
			id: overlayRect
			anchors.fill: parent
			color: Appearance.colors.m3surface
			opacity: root.startAnim ? 0.5 : 0
			Behavior on opacity {
				NumberAnimation { duration: animation_time; easing.type: easingType }
			}
		}
    }

	// Top part of the lock screen
    Rectangle {
		id: topBar
        anchors {
            left: parent.left
            right: parent.right
        }
        color: Appearance.colors.m3surface
        height: root.startAnim ? 50 : 0

        Behavior on height {
            NumberAnimation { duration: animation_time; easing.type: easingType }
        }
    }

	Corners {
		anchors.fill: undefined
		anchors.top: topBar.bottom
		anchors.left: topBar.left
		anchors.right: topBar.right

        cornerType: "inverted"
        cornerHeight: 20
        color: Appearance.colors.m3surface
        corners: [0,1]
    }

	// we only need the battery n wifi n bluetooth stuff :skull:
	BarContainer {
		opacity: root.startAnim ? 1 : 0
		Behavior on opacity {
            NumberAnimation { duration: animation_time; easing.type: easingType }
        }
		inLockScreen: true
		anchors {
			left: parent.left
			right: parent.right
			top: Preferences.barPosition === "top" ? topBar.bottom : undefined
			bottom: Preferences.barPosition === "bottom" ? bottomBar.top : undefined
			fill: null;
		}
	}
	ColumnLayout {
		opacity: root.startAnim ? 1 : 0
		Behavior on opacity {
            NumberAnimation { duration: animation_time; easing.type: easingType }
        }
		spacing: 10
		anchors {
			top: Preferences.barPosition === "top" ? topBar.bottom : undefined
			bottom: Preferences.barPosition === "bottom" ? bottomBar.top : undefined
			topMargin: 20
			bottomMargin: 20
			horizontalCenter: parent.horizontalCenter
		}

		MaterialIcon {
			icon: "lock"
			font.pixelSize: 26
			color: Appearance.colors.m3on_background
			Layout.alignment: Qt.AlignHCenter
		}

		Text {
			id: weatherLabel
			text:"bro doesn't have internet"
			font.pixelSize: 16
			color: Appearance.colors.m3on_background
			Layout.alignment: Qt.AlignHCenter

			Process {
				running: true
				command: ["sh", "-c", "curl -s 'wttr.in/?format=%l+%t'"]
				stdout: StdioCollector {
					onStreamFinished: weatherLabel.text = text.trim()
				}
			}
		}
	}

	// Bottom part of the lock screen
    Rectangle {
		id: bottomBar
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        color: Appearance.colors.m3surface
        height: root.startAnim ? 50 : 0

        Behavior on height {
            NumberAnimation { duration: animation_time; easing.type: easingType }
        }
    }

	ColumnLayout {
		opacity: root.startAnim ? 1 : 0
		Behavior on opacity {
            NumberAnimation { duration: animation_time; easing.type: easingType }
        }
		spacing: 10
		anchors {
			bottomMargin: 20
			topMargin: 20
			top: Preferences.barPosition === "bottom" ? topBar.bottom : undefined
			bottom: Preferences.barPosition === "top" ? bottomBar.top : undefined
			horizontalCenter: parent.horizontalCenter
		}
		Text {
			visible: Mpris.active
			text: Mpris.active?.trackTitle + " / " + Mpris.active?.trackArtist ?? ""
			font.pixelSize: 16
			color: Appearance.colors.m3on_background
		}
	}
	CavaVisualizer {
		opacity: root.startAnim ? 1 : 0
		Behavior on opacity {
            NumberAnimation { duration: animation_time; easing.type: easingType }
        }
		visible: Mpris.active
		position: Preferences.barPosition === "top" ? "bottom" : "top" // lmfao
		width: screen?.width ?? 800
		anchors {
			top: Preferences.barPosition === "bottom" ? topBar.bottom : undefined
			bottom: Preferences.barPosition === "top" ? bottomBar.top : undefined
			horizontalCenter: parent.horizontalCenter
		}
	}

	ColumnLayout {
		opacity: root.startAnim ? 1 : 0
		Behavior on opacity {
            NumberAnimation { duration: animation_time; easing.type: easingType }
        }
		spacing: -5
		anchors {
			bottomMargin: 20
			topMargin: 20
			top: Preferences.barPosition === "bottom" ? topBar.bottom : undefined
			bottom: Preferences.barPosition === "top" ? bottomBar.top : undefined
			left: Preferences.barPosition === "bottom" ? topBar.left : bottomBar.left
			leftMargin: 40 + (Preferences.smallBar ? Preferences.barPadding : 0)
		}
		Text {
			id: timeLabel
			font.pixelSize: 46
			font.bold: true
			color: Appearance.colors.m3on_background
		}
		Text {
			id: dateLabel
			font.pixelSize: 24
			color: Appearance.colors.m3on_background
		}
		Process {
			id: timeProc
			command: ["date", "+%H:%M"]
			running: true

			stdout: StdioCollector {
				onStreamFinished: timeLabel.text = this.text.trim()
			}
		}
		Process {
			id: dateProc
			command: ["date", "+%A, %d/%m"]
			running: true

			stdout: StdioCollector {
				onStreamFinished: dateLabel.text = this.text.trim()
			}
		}
		Timer {
			interval: 60000
			running: true
			repeat: true
			onTriggered: {
				timeProc.running = true
				dateProc.running = true
			}
		}
	}
	Corners {
		anchors.fill: undefined
		anchors.bottom: bottomBar.top
		anchors.left: bottomBar.left
		anchors.right: bottomBar.right

        cornerType: "inverted"
        cornerHeight: 20
        color: Appearance.colors.m3surface
        corners: [2,3]
    }
    ColumnLayout {
		layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
        	shadowOpacity: root.startAnim ? 1 : 0

            shadowBlur: 32
            shadowScale: 2

			Behavior on shadowOpacity {
				NumberAnimation { duration: animation_time; easing.type: easingType }
			}
        }
		scale: root.startAnim ? 1 : 0.9
		opacity: root.startAnim ? 1 : 0
		
		Behavior on scale {
			NumberAnimation { duration: animation_time; easing.type: easingType }
		}
		Behavior on opacity {
			NumberAnimation { duration: animation_time; easing.type: easingType }
		}
        anchors.centerIn: parent
        spacing: 20

		ClippingRectangle {
			implicitWidth: 200
			implicitHeight: 200
			radius: 100
			Image {
				id: logo
				source: Appearance.profileImage
				anchors.fill: parent
				smooth: true
			}
            Layout.alignment: Qt.AlignHCenter
		}

		Label {
			id: userLabel
			text: Quickshell.env("USER")
			font.bold: true
			color: Appearance.colors.m3on_background
			font.pixelSize: 32
			horizontalAlignment: Text.AlignHCenter
			Layout.alignment: Qt.AlignHCenter
		}

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            StyledTextField {
                id: passwordBox
                implicitWidth: 300
    			padding: 15
				leftPadding: 15
				radius: 30
                icon: ""
                placeholder: "Enter password"
                focus: true
				horizontalAlignment: Text.AlignHCenter

                enabled: !root.context.unlockInProgress
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhSensitiveData

                onTextChanged: root.context.currentText = this.text
                onAccepted: root.context.tryUnlock()

                Connections {
                    target: root.context
                    function onCurrentTextChanged() {
                        passwordBox.text = root.context.currentText;
                    }
                }
            }

        }

        Label {
            visible: root.context.showFailure
            text: "Incorrect password"
            color: "red"
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
		}
    }
	Connections {
		target: context
		function onUnlocked() {
			startAnim = false
			Cava.close()
		}
	}
	Component.onCompleted: {
        startAnim = true

        passwordBox.forceActiveFocus()
    }
}
