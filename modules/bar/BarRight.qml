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
    property bool inLockScreen: false
    
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

            Item {
                visible: !inLockScreen
                implicitWidth: mprisTray.width
                implicitHeight: mprisTray.height
                MprisTray { id:mprisTray }
            }
            Audio {}
            NetworkTray {}
            BluetoothTray {}
            Battery {}
        }
    }
}


