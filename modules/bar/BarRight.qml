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

    RowLayout {
        id: childContent
        spacing: 10
        Item {
            visible: !inLockScreen
            implicitWidth: mprisTray.width
            implicitHeight: mprisTray.height
            Layout.alignment: Qt.AlignVCenter
            MprisTray { id: mprisTray }
        }

        Tray {
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            implicitWidth: trays.implicitWidth + 20
            implicitHeight: 25
            Layout.alignment: Qt.AlignVCenter

            StyledRectangle {
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

                NotifTray {}
                AudioTray {}
                NetworkTray {}
                BluetoothTray {}
            }
        }

        Battery {
            Layout.alignment: Qt.AlignVCenter
        }

        PrivacyIndicator {
            Layout.alignment: Qt.AlignVCenter
            visible: Preferences.bar.position === "top" && Serv.Privacy.hasAnyActiveAccess
        }
    }
}
