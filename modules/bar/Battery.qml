import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.components
import qs.modules
import qs.preferences
import qs.services
import qs.windows.quickpanel

Item {
    id: root

    property bool verticalMode: false
    implicitWidth: verticalMode ? 32 : 50
    implicitHeight: verticalMode ? 60 : 25

    visible: Power.laptop

    property int lowBatteryLevel: 15
    property int notifiedLevel: -1

    property real pct: Power.batteries.length > 0 ? Power.percentage*100 : 0
    property string pctText: Math.floor(pct) + "%"

    property color batteryColor: {
        if (!Power.onBattery) return Appearance.colors.m3primary;
        if (pct < 20) return Appearance.colors.m3error;
        if (pct < 50) return Appearance.colors.m3secondary;
        return Appearance.colors.m3primary;
    }

    property string icon: !Power.onBattery ? "bolt" : ""

    function isLowBattery() {
        return pct < lowBatteryLevel;
    }

    function clampPercent(x) {
        return Math.max(0, Math.min(100, x)) / 100;
    }

    Connections {
        target: Power

        function onPercentageChanged() {
            if (!Power.onBattery)
                return;

            const p = Math.floor(pct);
            if (p === notifiedLevel) return;

            if (p <= 5 && notifiedLevel > 5) {
                notifiedLevel = 5;
                notify("Battery critically low", "Emergency shutdown imminent unless plugged in.");
            } else if (p <= lowBatteryLevel && notifiedLevel > lowBatteryLevel) {
                notifiedLevel = lowBatteryLevel;
                notify("Battery very low", "Please plug in your charger now.");
            } else if (p <= 20 && notifiedLevel > 20) {
                notifiedLevel = 20;
                notify("Low battery", "Consider plugging in your charger.");
            }
        }

        function notify(title, body) {
            Quickshell.execDetached({
                command: ["notify-send", title, body]
            });
        }
    }

    Component {
        id: batteryDisplay

        GridLayout {
            columns: root.verticalMode ? 1 : 2
            rows: root.verticalMode ? 2 : 1
            rowSpacing: root.verticalMode ? 2 : 0
            columnSpacing: root.verticalMode ? 0 : 2

            MaterialIcon {
                icon: root.icon
                font.pixelSize: root.verticalMode ? 14 : 14
                Layout.alignment: Qt.AlignHCenter
                color: iconColor
            }

            StyledText {
                text: root.pctText
                font.pixelSize: root.verticalMode ? 11 : 12
                font.family: "Outfit Medium"
                Layout.alignment: Qt.AlignHCenter
                color: labelColor
            }
        }
    }

    ClippingRectangle {
        id: background
        anchors.fill: parent
        radius: 100
        color: Colors.opacify(root.batteryColor, 0.2)

        Loader {
            x: (root.width - width) / 2
            y: (root.height - height) / 2
            sourceComponent: batteryDisplay
            property color iconColor: root.batteryColor
            property color labelColor: root.batteryColor
        }

        Rectangle {
            id: bar
            clip: true

            width: verticalMode ? parent.width : parent.width * root.clampPercent(root.pct)
            height: verticalMode ? parent.height * root.clampPercent(root.pct) : parent.height
            color: root.batteryColor

            Behavior on width {
                NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
            }
            Behavior on height {
                NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
            }

            Loader {
                x: (root.width - width) / 2
                y: (root.height - height) / 2
                sourceComponent: batteryDisplay
                property color iconColor: Appearance.colors.m3surface
                property color labelColor: Appearance.colors.m3surface
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: Quickshell.execDetached({
            command: ["whisker", "ipc", "settings", "open", "power"]
        })
    }

    HoverHandler { id: hover }

    StyledPopout {
        hoverTarget: hover
        hCenterOnItem: true
        interactable: true

        Component {
            Item {
                implicitWidth: 250
                implicitHeight: content.height + 24

                ColumnLayout {
                    id: content
                    anchors.centerIn: parent
                    width: parent.width - 24
                    spacing: 12

                    StyledText {
                        text: "Batteries - " + root.pct.toFixed(1) + "%"
                        font.pixelSize: 16
                        font.bold: true
                        color: Appearance.colors.m3on_surface
                    }

                    Repeater {
                        model: Power.batteries

                        delegate: ColumnLayout {
                            spacing: 8
                            Layout.fillWidth: true

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                StyledText {
                                    text: "Battery " + (index + 1)
                                    font.pixelSize: 13
                                    font.bold: true
                                    color: Appearance.colors.m3on_surface
                                }

                                StyledText {
                                    text: modelData.model
                                    font.pixelSize: 10
                                    color: Colors.opacify(Appearance.colors.m3on_surface, 0.6)
                                }
                            }

                            ClippingRectangle {
                                Layout.fillWidth: true
                                height: 10
                                radius: 5
                                color: Colors.opacify(root.batteryColor, 0.2)

                                Rectangle {
                                    width: parent.width * modelData.percentage
                                    height: parent.height
                                    radius: 5
                                    color: root.batteryColor

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: Appearance.animation.medium
                                            easing.type: Appearance.animation.easing
                                        }
                                    }
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true

                                StyledText {
                                    text: (modelData.percentage * 100).toFixed(0) + "%"
                                    font.pixelSize: 12
                                    color: Appearance.colors.m3on_surface
                                }

                                Item { Layout.fillWidth: true }

                                StyledText {
                                    text: Power.onBattery
                                        ? (modelData.timeToEmpty > 0 ? Utils.formatSeconds(modelData.timeToEmpty) : "Calculating")
                                        : (modelData.timeToFull > 0 ? Utils.formatSeconds(modelData.timeToFull) : "Fully charged")
                                    font.pixelSize: 12
                                    color: Colors.opacify(Appearance.colors.m3on_surface, 0.7)
                                }
                            }
                        }
                    }

                    ExpPowerProfile { showText: false }
                }
            }
        }
    }
}
