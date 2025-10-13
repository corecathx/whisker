import QtQuick
import QtQuick.Layouts
import qs.modules
import qs.components

SetupPage {
    signal nextRequested()
    signal quitRequested()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10
        width: parent.width * 0.8

        Image {
            source: Appearance.whiskerIcon
            sourceSize: Qt.size(100,100)
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            text: "Hey there!"
            color: Appearance.colors.m3on_surface
            font.pixelSize: 32
            font.family: "Outfit SemiBold"
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            text: "First time here? Let me help you set things up"
            color: Appearance.colors.m3on_surface_variant
            font.pixelSize: 14
            font.family: "Outfit"
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Item { height: 0 }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10

            StyledButton {
                text: "Nah..."
                secondary: true
                onClicked: confirmDialog.show()
            }

            StyledButton {
                text: "Okay!"
                icon: "arrow_forward"
                onClicked: nextRequested()
            }
        }
    }

    ConfirmModal {
        id: confirmDialog
        title: "Hold up!"
        message: "Are you sure you want to skip the setup? I mean that's fine but I'm here to make things easier for you"
        confirmText: "Yeah, skip it"
        confirmIcon: "close"
        cancelText: "Let me think..."
        onConfirmed: quitRequested()
    }
}
