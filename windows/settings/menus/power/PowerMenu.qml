import QtQuick
import QtQuick.Layouts

import Quickshell.Widgets
import Quickshell.Io

import qs.preferences
import qs.windows.quickpanel
import qs.components
import qs.modules
import qs.services

BaseMenu {
    id: root

    property real lowHealthThreshold: 70

    title: "Power"
    description: "View battery status and power options."

    BaseCard {
        RowLayout {
            width: parent.width
            spacing: 14

            StyledText {
                text: Power.onBattery ? "battery_full" : "power"
                font.family: "Material Symbols Rounded"
                font.pixelSize: 32
                color: Appearance.colors.m3primary
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    text: Power.onBattery ? "On battery" : "Plugged in"
                    font.pixelSize: 18
                    font.bold: true
                    color: Appearance.colors.m3on_background
                }

                StyledText {
                    text: Power.onBattery
                        ? "Using battery power"
                        : "Connected to AC power"
                    font.pixelSize: 12
                    color: Colors.opacify(
                        Appearance.colors.m3on_background,
                        0.65
                    )
                }
            }
        }
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 14

            StyledText {
                text: "Batteries"
                font.pixelSize: 20
                font.bold: true
                color: Appearance.colors.m3on_background
            }

            Repeater {
                model: Power.batteries

                delegate: ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10

                        StyledText {
                            text: modelData.percentage >= 0.9
                                ? "battery_full"
                                : modelData.percentage >= 0.6
                                    ? "battery_5_bar"
                                    : modelData.percentage >= 0.3
                                        ? "battery_3_bar"
                                        : "battery_1_bar"

                            font.family: "Material Symbols Rounded"
                            font.pixelSize: 24

                            color: modelData.percentage <= 0.15
                                ? Appearance.colors.m3error
                                : Appearance.colors.m3on_background
                        }

                        ColumnLayout {
                            spacing: 1

                            StyledText {
                                text: modelData.model || "Battery " + (index + 1)
                                font.pixelSize: 14
                                font.bold: true
                                color: Appearance.colors.m3on_background
                            }

                            StyledText {
                                text: modelData.healthSupported
                                    ? modelData.healthPercentage.toFixed(1) + "% health"
                                    : "Health information unavailable"

                                font.pixelSize: 11
                                color: modelData.healthSupported &&
                                       modelData.healthPercentage < lowHealthThreshold
                                    ? Appearance.colors.m3error
                                    : Colors.opacify(
                                        Appearance.colors.m3on_background,
                                        0.6
                                    )
                            }
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledText {
                            text: Math.round(modelData.percentage * 100) + "%"
                            font.pixelSize: 15
                            font.bold: true
                            color: Appearance.colors.m3on_background
                        }
                    }

                    StyledProgressBar {
                        Layout.fillWidth: true
                        fill: modelData.percentage
                    }

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            text: modelData.healthSupported &&
                                  modelData.healthPercentage < lowHealthThreshold
                                ? "Battery health is low"
                                : Power.onBattery
                                    ? Utils.formatSeconds(modelData.timeToEmpty) || "Calculating"
                                    : Utils.formatSeconds(modelData.timeToFull) || "Fully charged"

                            font.pixelSize: 11
                            color: modelData.healthSupported &&
                                   modelData.healthPercentage < lowHealthThreshold
                                ? Appearance.colors.m3error
                                : Colors.opacify(
                                    Appearance.colors.m3on_background,
                                    0.6
                                )
                        }

                        Item {
                            Layout.fillWidth: true
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Appearance.colors.m3outline_variant
                        visible: index < Power.batteries.length - 1
                    }
                }
            }
        }
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 12

            StyledText {
                text: "Power Profile"
                font.pixelSize: 20
                font.bold: true
                color: Appearance.colors.m3on_background
            }

            ExpPowerProfile {}
        }
    }
}