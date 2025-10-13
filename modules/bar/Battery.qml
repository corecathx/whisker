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

    property var low_battery_level: 15
    property int notifiedLevel: -1
    property string battery: Power.batteries.length > 0
        ? (Math.round(Power.percentage * 100).toFixed(1)) + ""
        : "0%"

    property color batteryColor: {
        if (!Power.onBattery) {
            return Appearance.colors.m3primary;
        }
        if (Power.percentage < 0.2) {
            return Appearance.colors.m3error;
        }
        if (Power.percentage < 0.5) {
            return Appearance.colors.m3secondary;
        }
        return Appearance.colors.m3primary;
    }

    function isLowBattery() {
        return parseFloat(root.battery) < root.low_battery_level;
    }

    // Notifications for battery levels
    Connections {
        target: Power
        function onPercentageChanged() {
            if (!Power.onBattery)
                return;

            const pct = Math.floor(Power.percentage * 100);
            if (pct === notifiedLevel)
                return;

            if (pct <= 5 && notifiedLevel > 5) {
                notifiedLevel = 5;
                Quickshell.execDetached({
                    command: ['notify-send', 'Battery critically low', 'Emergency shutdown imminent unless plugged in.']
                });
            } else if (pct <= low_battery_level && notifiedLevel > low_battery_level) {
                notifiedLevel = low_battery_level;
                Quickshell.execDetached({
                    command: ['notify-send', 'Battery very low', 'Please plug in your charger now.']
                });
            } else if (pct <= 20 && notifiedLevel > 20) {
                notifiedLevel = 20;
                Quickshell.execDetached({
                    command: ['notify-send', 'Low battery', 'Consider plugging in your charger.']
                });
            }
        }
    }

    property string icon: {
        if (!Power.onBattery) return "bolt";
        return "";
    }

    ClippingRectangle {
        id: background
        anchors.fill: parent
        radius: 100
        color: Colors.opacify(batteryColor, 0.2)

        GridLayout {
            id: textLayer
            anchors.centerIn: parent
            columns: root.verticalMode ? 1 : 2
            rows: root.verticalMode ? 2 : 1
            rowSpacing: root.verticalMode ? 2 : 0
            columnSpacing: root.verticalMode ? 0 : 2

            MaterialIcon {
                icon: root.icon
                font.pixelSize: root.verticalMode ? 14 : 16
                color: batteryColor
                Layout.alignment: Qt.AlignHCenter
            }

            StyledText {
                id: batteryText
                text: root.battery
                font.pixelSize: root.verticalMode ? 11 : 12
                color: batteryColor
                font.bold: root.isLowBattery()
                Layout.alignment: Qt.AlignHCenter
            }
        }

        Rectangle {
            id: bar
            clip: true
            anchors.top: verticalMode ? undefined : parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: verticalMode ? parent.right : undefined
            width: verticalMode ? root.width : root.width * Math.min(Math.max(parseFloat(battery), 0), 100) / 100
            height: verticalMode ? root.height * Math.min(Math.max(parseFloat(battery), 0), 100) / 100 : root.height
            color: batteryColor

            Behavior on width {
                NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
            }

            GridLayout {
                id: textLayer2
                columns: root.verticalMode ? 1 : 2
                rows: root.verticalMode ? 2 : 1
                rowSpacing: root.verticalMode ? 2 : 0
                columnSpacing: root.verticalMode ? 0 : 2
                x: (root.implicitWidth - width) / 2
                y: (root.implicitHeight - height) / 2

                MaterialIcon {
                    icon: root.icon
                    font.pixelSize: root.verticalMode ? 14 : 16
                    color: Appearance.colors.m3surface
                    Layout.alignment: Qt.AlignHCenter
                }

                StyledText {
                    text: root.battery
                    font.pixelSize: root.verticalMode ? 11 : 12
                    color: Appearance.colors.m3surface
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
        MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached({
                command: ['whisker', 'ipc', 'settings', 'open', 'power']
            })
        }
    }

    HoverHandler {
        id: hover
    }

    StyledPopout {
        hoverTarget: hover
        hCenterOnItem: true
        interactable: true
        Component {
            Item {
                implicitWidth: 250
                implicitHeight: contentColumn.height + 24

                ColumnLayout {
                    id: contentColumn
                    anchors.centerIn: parent
                    width: parent.width - 24
                    spacing: 12

                    StyledText {
                        text: "Batteries"
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
                                spacing: 6
                                Layout.fillWidth: true

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
                                color: Colors.opacify(batteryColor, 0.2)

                                Rectangle {
                                    width: parent.width * modelData.percentage
                                    height: parent.height
                                    radius: 5
                                    color: batteryColor

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

                    ExpPowerProfile {
                        showText: false
                    }
                }
            }
        }
    }

}
