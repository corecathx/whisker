import QtQuick
import QtQuick.Layouts
import qs.whisker.modules
import qs.whisker.components

SetupPage {
    signal closeRequested()

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 10

        StyledText {
            text: "✨"
            font.pixelSize: 64
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            text: "You're all set!"
            color: Appearance.colors.m3on_surface
            font.pixelSize: 32
            font.family: "Outfit SemiBold"
            Layout.alignment: Qt.AlignHCenter
        }

        StyledText {
            text: "Thank you for using Whisker!"
            color: Appearance.colors.m3on_surface_variant
            font.pixelSize: 14
            font.family: "Outfit"
            Layout.alignment: Qt.AlignHCenter
        }


        StyledButton {
            text: "Close"
            Layout.alignment: Qt.AlignHCenter
            onClicked: closeRequested()
        }
    }
}
