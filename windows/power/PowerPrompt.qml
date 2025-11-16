import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

import qs.modules
import qs.windows
import qs.services
import qs.components
import qs.components.effects

Scope {
    id: root
    property bool active: false
    property var window: null
    property string action: ""

    IpcHandler {
        target: "power"
        function off() {
            root.action = "off";
            root.active = true;
        }

        function reboot() {
            root.action = "reboot";
            root.active = true;
        }

        function suspend() {
            root.action = "suspend";
            root.active = true;
        }
    }

    LazyLoader {
        active: root.active
        component: FullscreenPrompt {
            id: window

            Component.onCompleted: root.window = window
            Component.onDestruction: root.window = null

            onFadeOutFinished: root.active = false

            Item {
                id: promptContainer
                anchors.centerIn: parent
                width: promptBg.width
                height: promptBg.height
                BaseShadow {}

                Rectangle {
                    id: promptBg
                    width: promptLayout.width + 40
                    height: promptLayout.height + 40
                    color: Appearance.colors.m3surface
                    radius: 20
                }

                ColumnLayout {
                    id: promptLayout
                    spacing: 20
                    anchors {
                        left: promptBg.left
                        leftMargin: 20
                        top: promptBg.top
                        topMargin: 20
                    }

                    ColumnLayout {
                        spacing: 5
                        MaterialIcon {
                            icon: {
                                switch (root.action) {
                                case "off":
                                    return "power_settings_new";
                                case "reboot":
                                    return "restart_alt";
                                case "suspend":
                                    return "bedtime";
                                default:
                                    return "power_settings_new";
                                }
                            }
                            color: root.action === "off" ? Appearance.colors.m3error : Appearance.colors.m3primary
                            font.pixelSize: 30
                            Layout.alignment: Qt.AlignHCenter
                        }
                        StyledText {
                            text: {
                                switch (root.action) {
                                case "off":
                                    return "Power Off";
                                case "reboot":
                                    return "reboot";
                                case "suspend":
                                    return "Suspend";
                                default:
                                    return "Power Options";
                                }
                            }
                            font.family: "Outfit SemiBold"
                            font.pixelSize: 20
                            Layout.alignment: Qt.AlignHCenter
                        }
                        StyledText {
                            text: "Are you sure you want to do this?" + (Hyprland.toplevels.values.length > 0 ? "\nMake sure to save your work before proceeding!" : "")
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                            wrapMode: Text.WordWrap
                        }
                    }

                    ColumnLayout {
                        visible: Hyprland.toplevels.values.length > 0
                        Layout.fillWidth: true
                        spacing: 10
                        StyledText {
                            text: "Active applications:"
                            font.pixelSize: 14
                            color: Appearance.colors.m3on_surface_variant
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredWidth: promptLayout.width - 40
                            Layout.preferredHeight: Math.min(appListContainer.childrenRect.height, 200)
                            color: "transparent"
                            clip: true

                            ColumnLayout {
                                id: appListContainer
                                width: parent.width
                                spacing: 10

                                Repeater {
                                    model: Hyprland.toplevels

                                    delegate: RowLayout {
                                        spacing: 10
                                        width: parent.width

                                        IconImage {
                                            source: Utils.getAppIcon(modelData.lastIpcObject.class)
                                            width: 26
                                            height: 26
                                        }

                                        StyledText {
                                            text: modelData.lastIpcObject.title || modelData.lastIpcObject.class || "Unknown"
                                            font.pixelSize: 12
                                            elide: Text.ElideRight
                                            width: parent.width - 36
                                        }
                                        Item {
                                            Layout.fillWidth: true
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5

                        StyledButton {
                            radius: 10
                            topRightRadius: 5
                            bottomRightRadius: 5
                            secondary: true
                            text: "Cancel"
                            onClicked: window.closeWithAnimation()
                        }

                        StyledButton {
                            radius: 10
                            topLeftRadius: 5
                            bottomLeftRadius: 5
                            text: {
                                switch (root.action) {
                                case "off":
                                    return "Power Off";
                                case "reboot":
                                    return "Reboot";
                                case "suspend":
                                    return "Suspend";
                                default:
                                    return "Confirm";
                                }
                            }
                            onClicked: {
                                switch (root.action) {
                                case "off":
                                    Quickshell.execDetached({
                                        command: ['systemctl', 'poweroff']
                                    });
                                    break;
                                case "reboot":
                                    Quickshell.execDetached({
                                        command: ['systemctl', 'reboot']
                                    });
                                    break;
                                case "suspend":
                                    Quickshell.execDetached({
                                        command: ['systemctl', 'suspend']
                                    });
                                    break;
                                }
                                window.closeWithAnimation();
                            }
                        }
                    }
                }
            }
        }
    }
}
