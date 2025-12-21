import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets
import qs.modules
import qs.services as Serv
import qs.preferences
import qs.components

Item {
    id: root
    property bool inLockScreen: false
    implicitHeight: childContent.height
    implicitWidth: childContent.width
    anchors.verticalCenter: parent.verticalCenter

    RowLayout {
        id: childContent
        spacing: 10
        Item {
            visible: !inLockScreen
            implicitWidth: mprisTray.width
            implicitHeight: mprisTray.height
            anchors.verticalCenter: parent.verticalCenter
            MprisTray { id: mprisTray }
        }

        Item {
            implicitWidth: trays.implicitWidth + 20
            implicitHeight: 25
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                id: bgRect
                anchors.fill: parent
                radius: 20
                color: Appearance.colors.m3surface_container
                opacity: !Preferences.bar.keepOpaque && !Serv.Hyprland.currentWorkspace.hasTilingWindow() ? 0 : 1

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }
            }

            Row {
                id: trays
                anchors.centerIn: bgRect
                spacing: 10
                anchors.verticalCenter: parent.verticalCenter

                NotifTray {}
                AudioTray {}
                NetworkTray {}
                BluetoothTray {}
            }
        }

        Battery {
            anchors.verticalCenter: parent.verticalCenter
        }

        PrivacyIndicator {
            anchors.verticalCenter: parent.verticalCenter
            visible: Preferences.bar.position === "top" && Serv.Privacy.hasAnyActiveAccess
        }
    }
}
