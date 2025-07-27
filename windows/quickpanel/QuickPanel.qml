import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import qs.modules
import qs.components
import qs.preferences
import qs.modules.bar
import Quickshell.Hyprland
import QtQuick.Controls

Scope {
    id: root
    property bool opened: false

    LazyLoader {
        active: Globals.visible_quickPanel

        PanelWindow {
            id: window
            anchors.top: ShellLayout.bar_position === 'top'
            margins.top: ShellLayout.bar_position === 'top' ? 10 : 0

            anchors.bottom: ShellLayout.bar_position === 'bottom'
            margins.bottom: ShellLayout.bar_position === 'bottom' ? 10 : 0

            anchors.left: true
            margins.left: 10

            WlrLayershell.layer: WlrLayer.Overlay

            implicitWidth: 450
            implicitHeight: 600
            color: 'transparent'

            Rectangle {
                anchors.fill: parent
                color: Appearance.panel_color
                radius: 20
            }

            HyprlandFocusGrab {
                id: grab
                windows: [ window ]
            }

            onVisibleChanged: {
                if (visible) grab.active = true;
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active) {
                        Globals.visible_quickPanel = false;
                    }
                }
            }

            ColumnLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 20

                RowLayout {
                    Layout.margins: 20
                    Layout.bottomMargin: 0
                    spacing: 20
                    Layout.fillWidth: true

                    ClippingRectangle {
                        width: 80
                        height: 80
                        radius: 20
                        color: "transparent"

                        IconImage {
                            anchors.fill: parent
                            source: Appearance.profileImage
                        }
                    }

                    ColumnLayout {
                        anchors.verticalCenter: parent.verticalCenter
                        Layout.fillWidth: true

                        Text {
                            text: Quickshell.env("USER")
                            font.pixelSize: 30
                            font.bold: true
                            font.letterSpacing: 2
                            color: Colors.foreground
                        }

                        RowLayout {
                            Battery {
                                id: battery
                            }
                            Text {
                                text: "- " + battery.remainingTime + " left"
                                font.pixelSize: 14
                                color: Colors.foreground
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }

                    MaterialSymbol {
                        icon: "settings"
                        font.pixelSize: 26
                        color: Colors.foreground
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                Globals.visible_settingsMenu = true
                                grab.active = false;
                            }
                        }
                    }
                }


                RowLayout {
                    height: 40
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    spacing: 20
                    BtnWifi {}
                    BtnBluetooth {}
                }

                RowLayout {
                    height: 40
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    spacing: 20
                    SdrVolume {}
                }

                RowLayout {
                    height: 40
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    spacing: 20
                    SdrBrightness {}
                }
            }
        }
    }
}
