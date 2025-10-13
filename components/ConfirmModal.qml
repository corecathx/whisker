import QtQuick
import QtQuick.Layouts
import qs.modules
import qs.components

Rectangle {
    id: root

    z: 200
    property string title: "Are you sure?"
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property string confirmIcon: ""
    property string cancelIcon: ""

    signal confirmed()
    signal cancelled()

    anchors.fill: parent
    color: Colors.opacify(Appearance.colors.m3scrim, 0.6)
    visible: false
    radius: 20

    function show() {
        visible = true
    }

    function hide() {
        visible = false
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {} // Prevent clicks from passing through
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.85, 400)
        height: dialogContent.height + 60
        radius: 20
        color: Appearance.colors.m3surface
        scale: parent.visible ? 1 : 0.9

        ColumnLayout {
            id: dialogContent
            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 10

            StyledText {
                text: root.title
                color: Appearance.colors.m3on_surface
                font.pixelSize: 24
                font.family: "Outfit SemiBold"
                Layout.alignment: Qt.AlignHCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            StyledText {
                visible: root.message !== ""
                text: root.message
                color: Appearance.colors.m3on_surface_variant
                font.pixelSize: 14
                font.family: "Outfit"
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
            Item {}
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                StyledButton {
                    text: root.cancelText
                    icon: root.cancelIcon
                    secondary: true
                    onClicked: {
                        root.hide()
                        root.cancelled()
                    }
                }

                StyledButton {
                    text: root.confirmText
                    icon: root.confirmIcon
                    onClicked: {
                        root.hide()
                        root.confirmed()
                    }
                }
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    opacity: visible ? 1 : 0
}
