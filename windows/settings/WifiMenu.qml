import QtQuick
import QtQuick.Layouts
import qs.preferences
import qs.components
import qs.modules
import qs.services

BaseMenu {
    title: "Wi-Fi"
    description: "Manage Wi-Fi networks and connections."

    ColumnLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 10
        anchors.margins: 10

        Text {
            text: "Work-In-Progress!"
            font.pixelSize: 18
            font.bold: true
            color: Appearance.colors.m3on_background
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "This menu is still unfinished! I'm sorry :']"
            font.pixelSize: 14
            color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
