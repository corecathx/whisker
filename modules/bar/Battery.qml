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

        StyledRectangle {
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
        id: mArea
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (popout.isVisible)
                popout.hide()
            else
                popout.show()
        }
    }

    HoverHandler {
        id: hover
    }

    StyledPopout {
        hoverTarget: hover
        hCenterOnItem: true
        Component {
            StyledText {
                text: {
                    let txt = Math.floor(Power.percentage * 100) + "%";
                    if (!Power.onBattery)
                        txt = "Charging " + txt;
                    else
                        txt = "Discharging " + txt;
                    return txt;
                }
                color: Appearance.colors.m3on_surface
                font.pixelSize: 14
            }
        }
    }


    StyledPopout {
        id: popout
        hoverTarget: hover
        interactable: true
        hCenterOnItem: true
        requiresHover: false
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

                            StyledProgressBar {
                                fill: modelData.percentage
                                height: 6
                                gap: 3
                                gapRadius: 1
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
