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
import qs.components.effects
import qs.preferences
import qs.modules.bar
import Quickshell.Hyprland

Scope {
    id: root
    property bool opened: false

    component StyledLargeButton: Rectangle {
        id: toggle
        property string icon: ""
        property string label: ""
        property string subtitle: ""
        property bool active: false
        signal clicked

        radius: 18
        color: active ? Appearance.colors.m3primary : Appearance.colors.m3surface_container_high
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }

        height: content.height + 20
        ColumnLayout {
            id: content
            anchors {
                top: parent.top
                left: parent.left
                margins: 10
            }
            spacing: 2

            MaterialIcon {
                icon: toggle.icon
                font.pixelSize: 20
                color: toggle.active ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface_variant
            }

            Item {
                Layout.fillHeight: true
            }

            StyledText {
                text: toggle.label
                font.pixelSize: 14
                font.family: "Outfit Medium"
                color: toggle.active ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface_variant
            }

            StyledText {
                text: toggle.subtitle
                font.pixelSize: 12
                color: toggle.active ? Appearance.colors.m3on_primary : Appearance.colors.m3on_surface_variant
                opacity: 0.7
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: toggle.clicked()
        }
    }
    component SliderControl: ColumnLayout {
        id: control
        property string icon: ""
        property string label: ""
        property real value: 50
        property alias useAnim: slide.useAnim

        RowLayout {
            MaterialIcon {
                icon: control.icon
                font.pixelSize: 20
                color: Appearance.colors.m3on_surface_variant
            }

            StyledText {
                text: control.label
                font.pixelSize: 14
                font.family: "Outfit Medium"
                color: Appearance.colors.m3on_surface_variant
            }

            Item {
                Layout.fillWidth: true
            }

            StyledText {
                text: Math.round(control.value) + "%"
                font.pixelSize: 12
                color: Appearance.colors.m3on_surface_variant
            }
        }

        StyledSlider {
            id: slide
            Layout.fillWidth: true
            value: control.value
            onValueChanged: control.value = value
        }
    }

    IpcHandler {
        target: "quickpanel"
        function toggle() {
            root.opened = !root.opened;
        }
    }

    LazyLoader {
        active: root.opened

        PanelWindow {
            id: window
            anchors.top: Preferences.bar.position !== 'bottom' || Preferences.verticalBar()
            margins.top: -10
            anchors.bottom: Preferences.bar.position === 'bottom'
            margins.bottom: Preferences.bar.position === 'bottom' ? -10 : 0

            anchors.left: Preferences.bar.position === 'left' || Preferences.horizontalBar()
            margins.left: Preferences.verticalBar() && Preferences.bar.small ? Preferences.bar.padding + 20 : -10
            anchors.right: Preferences.bar.position === 'right'
            margins.right: -10
            WlrLayershell.layer: WlrLayer.Top

            implicitWidth: 460 + 20
            implicitHeight: 600 + 20
            color: 'transparent'

            Item {
                anchors.fill: parent
                BaseShadow {}

                Rectangle {
                    id: bg
                    anchors.fill: parent
                    color: Appearance.panel_color
                    radius: 20
                    anchors.margins: 20
                }

                ColumnLayout {
                    anchors.fill: bg
                    anchors.margins: 20
                    spacing: 10

                    RowLayout {
                        spacing: 16

                        ProfileIcon {
                            implicitWidth: 70
                            radius: 18
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            StyledText {
                                text: Quickshell.env("USER")
                                font.pixelSize: 26
                                font.family: "Outfit SemiBold"
                                color: Appearance.colors.m3on_background
                            }

                            RowLayout {
                                IconImage {
                                    width: 20
                                    height: 20
                                    source: Quickshell.iconPath(System.logo)
                                }
                                StyledText {
                                    text: 'Uptime ' + Utils.formatSeconds(System.uptime) + " • " + Power.chargingInfo
                                    color: Appearance.colors.m3on_surface_variant
                                    font.pixelSize: 12
                                }
                            }
                        }
                        Item {
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 5

                            Rectangle {
                                width: 40
                                height: 40
                                radius: 10
                                color: settingsArea.pressed ? Appearance.colors.m3surface_container : Appearance.colors.m3surface_container_high

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Appearance.animation.fast
                                    }
                                }

                                MaterialIcon {
                                    icon: "settings"
                                    font.pixelSize: 20
                                    color: Appearance.colors.m3on_surface
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: settingsArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        Quickshell.execDetached({
                                            command: ['whisker', 'ipc', 'settings', 'open', '""']
                                        });
                                        root.opened = false;
                                    }
                                }
                            }
                            Rectangle {
                                width: 40
                                height: 40
                                radius: 10
                                color: powerArea.pressed ? Appearance.colors.m3surface_container : Appearance.colors.m3surface_container_high

                                Behavior on color {
                                    ColorAnimation {
                                        duration: Appearance.animation.fast
                                    }
                                }

                                MaterialIcon {
                                    icon: "power_settings_new"
                                    font.pixelSize: 20
                                    color: Appearance.colors.m3on_surface
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    id: powerArea
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        popout.show();
                                    }
                                }
                                HoverHandler {
                                    id: hover
                                }
                                StyledPopout {
                                    id: popout
                                    hoverTarget: hover
                                    requiresHover: false
                                    interactable: true
                                    Component {
                                        Repeater {
                                            model: [
                                                {
                                                    icon: "power_settings_new",
                                                    label: "Power off",
                                                    command: ["whisker", "ipc", "power", "off"],
                                                    color: Appearance.colors.m3error
                                                },
                                                {
                                                    icon: "restart_alt",
                                                    label: "Reboot",
                                                    command: ["whisker", "ipc", "power", "reboot"]
                                                },
                                                {
                                                    icon: "bedtime",
                                                    label: "Suspend",
                                                    command: ["whisker", "ipc", "power", "suspend"]
                                                }
                                            ]

                                            delegate: Item {
                                                width: 150
                                                height: 30

                                                Rectangle {
                                                    anchors.fill: parent
                                                    radius: 5
                                                    color: mArea.containsMouse ? Appearance.colors.m3surface_container : Appearance.colors.m3surface
                                                }

                                                RowLayout {
                                                    anchors {
                                                        top: parent.top
                                                        left: parent.left
                                                        margins: 5
                                                    }
                                                    spacing: 10

                                                    MaterialIcon {
                                                        icon: modelData.icon
                                                        font.pixelSize: 18
                                                        color: modelData.color ?? Appearance.colors.m3on_surface
                                                    }

                                                    StyledText {
                                                        text: modelData.label
                                                        font.pixelSize: 14
                                                        color: modelData.color ?? Appearance.colors.m3on_surface
                                                    }
                                                }

                                                MouseArea {
                                                    id: mArea
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    cursorShape: Qt.PointingHandCursor

                                                    onClicked: {
                                                        Quickshell.execDetached({
                                                            command: modelData.command
                                                        });
                                                        root.opened = false;
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 10
                        columnSpacing: 10

                        StyledLargeButton {
                            Layout.fillWidth: true
                            icon: Network.icon
                            label: Network.wifiLabel
                            subtitle: Network.wifiStatus
                            active: Network.wifiEnabled
                            onClicked: {
                                Network.toggleWifi();
                            }
                        }

                        StyledLargeButton {
                            Layout.fillWidth: true
                            icon: Bluetooth.icon
                            label: Bluetooth.defaultAdapter.enabled && Bluetooth.activeDevice ? Bluetooth.activeDevice.name : "Bluetooth"
                            subtitle: Bluetooth.defaultAdapter.enabled ? "On" : "Off"
                            active: Bluetooth.defaultAdapter.enabled
                            onClicked: Bluetooth.defaultAdapter.enabled = !Bluetooth.defaultAdapter.enabled
                        }
                    }

                    ExpPowerProfile {}

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.colors.m3outline_variant
                    }

                    SliderControl {
                        icon: Audio.volume === 0 ? "volume_off" : Audio.volume < 0.5 ? "volume_down" : "volume_up"
                        value: Audio.volume * 100
                        label: "Volume"

                        onValueChanged: {
                            Audio.setVolume(value / 100);
                        }
                    }
                    SliderControl {
                        id: briSlider
                        label: "Brightness"
                        icon: Brightness.icon

                        value: Brightness.value * 100

                        onValueChanged: {
                            Brightness.set(value / 100);
                        }

                        Connections {
                            target: Brightness
                            function onBrightnessChanged(newValue) {
                                briSlider.value = newValue * 100;
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.colors.m3outline_variant
                    }

                    GithubContribCalendar {
                        Layout.fillWidth: true
                    }

                    Item {
                        Layout.fillHeight: true
                    }
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [window, popout.instance]
            }

            onVisibleChanged: {
                if (visible)
                    grab.active = true;
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active) {
                        root.opened = false;
                    }
                }
            }
        }
    }
}
