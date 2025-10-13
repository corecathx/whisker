import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules
import qs.services
import qs.components
import qs.preferences
import qs.modules.bar
import Quickshell.Hyprland
Scope {
    id: root
    property bool opened: false
    LazyLoader {
        active: Globals.visible_quickPanel

        PanelWindow {
            id: window
            anchors.top: Preferences.barPosition !== 'bottom'|| Preferences.verticalBar()
            margins.top: -10
            anchors.bottom: Preferences.barPosition === 'bottom'
            margins.bottom:  Preferences.barPosition === 'bottom' ? -10 : 0


            anchors.left: Preferences.barPosition === 'left' || Preferences.horizontalBar()
            margins.left: Preferences.verticalBar() && Preferences.smallBar ? Preferences.barPadding + 20 : -10
            anchors.right: Preferences.barPosition === 'right'
            margins.right: -10
            WlrLayershell.layer: WlrLayer.Top

            implicitWidth: 450 + 20
            implicitHeight: 600 + 20
            color: 'transparent'

            Item {
                anchors.fill: parent

                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                    shadowScale: 1
                }
                Rectangle {
                    id: bgRectangle
                    anchors.fill: parent

                    color: Appearance.panel_color
                    radius: 20
                    anchors.margins: 20
                }
                Item {
                    Layout.fillWidth: true
                    anchors {
                        left: bgRectangle.left
                        right: bgRectangle.right
                        top: bgRectangle.top
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
                                //anchors.verticalCenter: parent.verticalCenter
                                Layout.fillWidth: true

                                StyledText {
                                    text: Quickshell.env("USER")
                                    font.pixelSize: 28
                                    font.bold: true
                                    font.letterSpacing: 2
                                    color: Appearance.colors.m3on_background
                                }

                                RowLayout {
                                    visible: Power.laptop

                                    Battery {
                                        id: battery
                                    }
                                    StyledText {
                                        text: {
                                            function formatSeconds(s: int) {
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

                                                return comps.join(" ") || null;
                                            }

                                            let output = "•  ";
                                            if (Power.onBattery)
                                                output += formatSeconds(Power.displayDevice.timeToEmpty) || "Calculating"
                                            else
                                                output += formatSeconds(Power.displayDevice.timeToFull) || "Fully charged"

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
                                //anchors.verticalCenter: parent.verticalCenter
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

                            // bluetooth
                            StyledButton {
                                Layout.fillWidth: true
                                implicitWidth: 0
                                icon: Bluetooth.icon
                                base_bg: !Bluetooth.defaultAdapter.enabled
                                    ? Appearance.colors.m3secondary_container
                                    : Appearance.colors.m3primary

                                base_fg: !Bluetooth.defaultAdapter.enabled
                                    ? Appearance.colors.m3on_secondary_container
                                    : Appearance.colors.m3on_primary
                                text: {
                                    if (Bluetooth.activeDevice) {
                                        if (Bluetooth.activeDevice.deviceName.length > 12) {
                                            return Bluetooth.activeDevice.deviceName.slice(0, 12) + "..."
                                        } else {
                                            return Bluetooth.activeDevice.deviceName
                                        }
                                    } else {
                                        return "Bluetooth"
                                    }
                                }
                                onClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                            }
                        }

                        ExpPowerProfile {}

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
        }
    }
}
