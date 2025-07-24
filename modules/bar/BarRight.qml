import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules

RowLayout {
    id: childContent
    anchors.fill: parent

    Item {
        Layout.fillWidth: true
    }


    Rectangle {
        radius: 40
        color: "transparent"
        Layout.fillHeight: true
        Layout.preferredWidth: contentRow.implicitWidth

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 10

            Mpris {}
            Audio {}
            Network {}
            Bluetooth {}
            Battery {}
        }
    }
}


