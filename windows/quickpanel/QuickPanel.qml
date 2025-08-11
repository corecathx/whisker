import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Widgets
import qs.modules
import qs.services
import qs.components
import qs.preferences
import qs.modules.bar
import Quickshell.Hyprland
import QtQuick.Controls

Scope {
    id: root
    property bool opened: false
    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }
    LazyLoader {
        active: Globals.visible_quickPanel

        PanelWindow {
            id: window
            anchors.top: Preferences.barPosition === 'top'
            margins.top: Preferences.barPosition === 'top' ? 10 : 0

            anchors.bottom: Preferences.barPosition === 'bottom'
            margins.bottom: Preferences.barPosition === 'bottom' ? 10 : 0

            anchors.left: true
            margins.left: Preferences.smallBar ? Preferences.barPadding + 10 : 10

            WlrLayershell.layer: WlrLayer.Top

            implicitWidth: 450
            implicitHeight: 600
            color: 'transparent'

            Rectangle {
                anchors.fill: parent
                color: Appearance.panel_color
                //border.color: Appearance.colors.m3primary
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
                            color: Appearance.colors.m3on_background
                        }

                        RowLayout {
                            visible: UPower.displayDevice.isLaptopBattery

                            Battery {
                                id: battery
                            }
                            Text {
                                text: {
                                    function formatSeconds(s: int, fallback: string): string {
                                        const day = Math.floor(s / 86400);
                                        const hr = Math.floor(s / 3600) % 60;
                                        const min = Math.floor(s / 60) % 60;

                                        let comps = [];
                                        if (day > 0)
                                            comps.push(`${day}d`);
                                        if (hr > 0)
                                            comps.push(`${hr}h`);
                                        if (min > 0)
                                            comps.push(`${min}m`);

                                        return comps.join(" ") || fallback;
                                    }

                                    let output = "- ";
                                    if (UPower.onBattery)
                                        output += formatSeconds(UPower.displayDevice.timeToEmpty, "Calculating...")
                                    else
                                        output += formatSeconds(UPower.displayDevice.timeToFull, "Fully charged")

                                    return output
                                }
                                font.pixelSize: 14
                                color: Appearance.colors.m3on_background
                            }
                        }
                    }
                    Item {
                        Layout.fillWidth: true
                    }

                    MaterialIcon {
                        icon: "settings"
                        font.pixelSize: 26
                        color: Appearance.colors.m3on_background
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
                    StyledSlider {
                        id: vlmSlider
                        value: Audio.volume * 100
                        
                        onValueChanged: {
                            Audio.setVolume(value/100)
                            if (value === 0) vlmSlider.icon = "volume_off";
                            else if (value <= 50) vlmSlider.icon = "volume_down";
                            else vlmSlider.icon = "volume_up";
                        }
                    }
                }
                RowLayout {
                    height: 40
                    Layout.leftMargin: 20
                    Layout.rightMargin: 20
                    spacing: 20
                    StyledSlider {
                        id: briSlider
                        
                        onValueChanged: {
                            Quickshell.execDetached(["sh", "-c", `brightnessctl set ${value}%`]);

                            const icons = ["brightness_empty", "brightness_5", "brightness_6", "brightness_7"];
                            if (value <= 0) {
                                briSlider.icon = icons[0];
                            } else {
                                const index = Math.min(icons.length - 1, Math.ceil(value / (100 / (icons.length - 1))));
                                briSlider.icon = icons[index];
                            }
                        }

                        Process {
                            id: brightnessReadProc
                            command: ["sh", "-c", "brightnessctl get && brightnessctl max"]
                            running: true
                            stdout: StdioCollector {
                                onStreamFinished: {
                                    const lines = text.trim().split('\n');
                                    if (lines.length >= 2) {
                                        const current = parseInt(lines[0])
                                        const maximum = parseInt(lines[1])
                                        if (!isNaN(current) && !isNaN(maximum) && maximum > 0) {
                                            const percent = (current / maximum) * 100
                                            briSlider.value = percent
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
