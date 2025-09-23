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
			opacity: root.startAnim ? 0.2 : 0
			Behavior on opacity {
				NumberAnimation { duration: animation_time; easing.type: easingType }
			}
		}
    }

	Item {
		id: loginContainer
		layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
        	shadowOpacity: root.startAnim ? 1 : 0
            shadowColor: Appearance.colors.m3shadow
            shadowBlur: 2
            shadowScale: 1

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
		implicitWidth: rowContainer.width + 40
		implicitHeight: rowContainer.height + 40
		
		Rectangle {
			id: loginBG
			color: Appearance.panel_color
			anchors.fill: parent
			radius: 40
		}

		RowLayout {
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.leftMargin: 20
			anchors.topMargin: 20
			spacing: 20
			id: rowContainer
			ClippingRectangle {
				implicitWidth: 100
				implicitHeight: 100
				radius: 100
				Image {
					id: logo
					source: Appearance.profileImage
					anchors.fill: parent
					smooth: true
				}
				Layout.alignment: Qt.AlignHCenter
			}

			ColumnLayout  {
				id: loginContent

				RowLayout {
					spacing: 10

					StyledTextField {
						id: passwordBox
						implicitWidth: 300
						padding: 15
						radius: 30
						icon: "person"
						placeholder: root.context.showFailure ? "Incorrect password" : Quickshell.env("USER")
						focus: true

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
			}
		}
	}

	Connections {
		target: context
		function onUnlocked() {
			startAnim = false
		}
	}
	Component.onCompleted: {
        startAnim = true

        passwordBox.forceActiveFocus()
    }
}
