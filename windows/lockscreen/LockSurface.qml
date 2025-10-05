import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.modules
import qs.modules.bar
import qs.components
import qs.services as Serv

WlSessionLockSurface {
	id: root
	required property LockContext context
	required property real animation_time
	property var easingType: Easing.OutExpo
	color: !root.startAnim ? "transparent" : Appearance.colors.m3surface
	Behavior on color { ColorAnimation { duration: animation_time; easing.type: easingType } }
	property bool startAnim: false
	property bool exiting: false
	ScreencopyView {
		id: background
		anchors.fill: parent
		captureSource: root.screen
		live: false
		layer.enabled: true
		layer.effect: MultiEffect {
			autoPaddingEnabled: false
			blurEnabled: true
			blur: root.startAnim ? 1 : 0

			blurMax: 32
			blurMultiplier: 1
			contrast: root.startAnim ? 0.05 : 0
			saturation: root.startAnim ? 0.1 : 0
			Behavior on blur { NumberAnimation { duration: animation_time; easing.type: easingType } }
			Behavior on contrast { NumberAnimation { duration: animation_time; easing.type: easingType } }
			Behavior on saturation { NumberAnimation { duration: animation_time; easing.type: easingType } }
		}
		scale: root.startAnim ? 1.1 : 1
		Behavior on scale { NumberAnimation { duration: animation_time; easing.type: easingType } }
		rotation: root.startAnim ? 0.25 : 0
		Behavior on rotation {
			NumberAnimation { duration: animation_time; easing.type: easingType }
		}
		Rectangle {
			id: overlayRect
			anchors.fill: parent
			color: Appearance.colors.m3surface
			opacity: root.startAnim ? 0.1 : 0
			Behavior on opacity {
				NumberAnimation { duration: animation_time; easing.type: easingType }
			}
		}
    }
	CavaVisualizer {
		anchors.bottom: parent.bottom
		anchors.left: parent.left
		anchors.right: parent.right
		opacity: root.startAnim ? 1 : 0
		height: 200
		multiplier: 2
		Behavior on opacity { NumberAnimation { duration: animation_time; easing.type: easingType } }
	}
	Item {
		id: centeredElements
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
		Behavior on scale { NumberAnimation { duration: animation_time; easing.type: easingType } }
		Behavior on opacity { NumberAnimation { duration: animation_time; easing.type: easingType } }

		anchors.centerIn: parent
		implicitWidth: centeredContainer.width + 40
		implicitHeight: centeredContainer.height + 40
		ColumnLayout {
			anchors.horizontalCenter: parent.horizontalCenter
			id: centeredContainer
			spacing: 10
			ColumnLayout {
				Layout.alignment: Qt.AlignHCenter 

				id: clockContainer
				spacing: 0
				Text { 
					text: Qt.formatDateTime(Serv.Time.date, "HH:mm")
					font.family: "Outfit ExtraBold"
					color: Appearance.colors.m3on_background
					font.pixelSize: 92
					Layout.alignment: Qt.AlignHCenter 
				} 
				Text { 
					text: Qt.formatDateTime(Serv.Time.date, "dddd, dd/MM")
					color: Appearance.colors.m3on_background
					font.pixelSize: 32 
					Layout.alignment: Qt.AlignHCenter 
				} 
			}

		}
	}

	PlayerDisplay {
		anchors.right: loginContainer.left
		anchors.rightMargin: 20
		anchors.bottom: loginContainer.bottom
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
		Behavior on scale { NumberAnimation { duration: animation_time; easing.type: easingType } }
		Behavior on opacity { NumberAnimation { duration: animation_time; easing.type: easingType } }
		artSize: 55
		titleSize: 14
		artistSize: 10
		iconSize: 36
		panelRadius: 40
		sliderHeight: 10
		padding: 20
		spacing: 20
	}
    InfoCard {
        icon: "error"
        backgroundColor: Appearance.colors.m3error
        contentColor: Appearance.colors.m3on_error
        title: "Error while authenticating."
        description: root.context.lastMessage
		radius: 40
				
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
		scale: root.context.accountLocked ? 1 : 0.9
		opacity: root.context.accountLocked ? 1 : 0
		Behavior on scale { NumberAnimation { duration: animation_time; easing.type: easingType } }
		Behavior on opacity { NumberAnimation { duration: animation_time; easing.type: easingType } }
		anchors.bottom: loginContainer.top
		anchors.bottomMargin: 20
		anchors.left: loginContainer.left
		anchors.right: loginContainer.right
    }
	Item {
		id: loginContainer
		property real shakeOffset: 0
		
		transform: Translate { x: loginContainer.shakeOffset }
		
		SequentialAnimation {
			id: shakeAnim
			NumberAnimation { target: loginContainer; property: "shakeOffset"; to: -10; duration: 50; easing.type: Easing.InOutQuad }
			NumberAnimation { target: loginContainer; property: "shakeOffset"; to: 10; duration: 50; easing.type: Easing.InOutQuad }
			NumberAnimation { target: loginContainer; property: "shakeOffset"; to: -5; duration: 50; easing.type: Easing.InOutQuad }
			NumberAnimation { target: loginContainer; property: "shakeOffset"; to: 5; duration: 50; easing.type: Easing.InOutQuad }
			NumberAnimation { target: loginContainer; property: "shakeOffset"; to: 0; duration: 50; easing.type: Easing.InOutQuad }
		}
		
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
		Behavior on scale { NumberAnimation { duration: animation_time; easing.type: easingType } }
		Behavior on opacity { NumberAnimation { duration: animation_time; easing.type: easingType } }

        anchors.bottom: parent.bottom
		anchors.bottomMargin: root.startAnim ? 40 : -80
		Behavior on anchors.bottomMargin { NumberAnimation { duration: animation_time; easing.type: easingType } }

		anchors.horizontalCenter: parent.horizontalCenter
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

			ProfileIcon {
				implicitWidth: 55
				implicitHeight: this.implicitWidth
				radius: 100
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
							function onShowFailureChanged() {
								if (root.context.showFailure) {
									shakeAnim.restart()
								}
							}
						}
					}

				}
			}
		}
	}

	Item {
		anchors.left: loginContainer.right
		anchors.leftMargin: 20
		anchors.bottom: loginContainer.bottom
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
		Behavior on scale { NumberAnimation { duration: animation_time; easing.type: easingType } }
		Behavior on opacity { NumberAnimation { duration: animation_time; easing.type: easingType } }

		implicitWidth: rightContainer.width + 40
		implicitHeight: rightContainer.height + 40
				
		Rectangle {
			id: loginBG2
			color: Appearance.panel_color
			anchors.fill: parent
			radius: 40
		}
		RowLayout {
			id: rightContainer
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.leftMargin: 20
			anchors.topMargin: 20
			spacing: 20
			Rectangle {
				implicitWidth: innerContainer.width + 40
				implicitHeight: 55
				color: Appearance.colors.m3surface_container
				radius: 20
				RowLayout {
					id: innerContainer
					anchors.verticalCenter: parent.verticalCenter
					anchors.left: parent.left
					anchors.leftMargin: 20
					spacing: 20
					NotifTray { Layout.alignment: Qt.AlignVCenter }
					Audio { Layout.alignment: Qt.AlignVCenter }
					NetworkTray { Layout.alignment: Qt.AlignVCenter }
					BluetoothTray { Layout.alignment: Qt.AlignVCenter }
					Battery { Layout.alignment: Qt.AlignVCenter }
				}
			}
			Rectangle {
				implicitWidth: 55
				implicitHeight: this.implicitWidth
				color: Appearance.colors.m3surface_container
				radius: 20
				MaterialIcon {
					icon: 'power_settings_new'
					color: Appearance.colors.m3on_surface
					font.pixelSize: 26
					anchors.centerIn: parent
				}
			}
		}
	}

	Connections {
		target: context
		function onUnlocked() {
			startAnim = false
			exiting = true
		}
	}
	Component.onCompleted: {
        startAnim = true

        passwordBox.forceActiveFocus()
    }
}