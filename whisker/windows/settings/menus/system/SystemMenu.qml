import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import qs.whisker.modules
import qs.whisker.components
import qs.whisker.components.material
import qs.whisker.services

import Quickshell
import Quickshell.Widgets

import qs.whisker.windows.settings.menus.system.components

BaseMenu {
    id: root

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 20

        StyledRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 110
            radius: Appearance.rounding.extraLarge
            color: Appearance.colors.m3surface_container_high

            RowLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 18

                M3CircularProgress {
                    Layout.preferredWidth: 64
                    Layout.preferredHeight: 64

                    color: Appearance.colors.m3primary
                    backgroundColor: Appearance.colors.m3primary_container
                    thickness: 4

                    phaseMult: 0.1
                    amplitude: 2
                    progress: 1

                    IconImage {
                        anchors {
                            fill: parent
                            margins: 16
                        }
                        source: Quickshell.iconPath(System.logo)
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 5

                    StyledText {
                        Layout.fillWidth: true
                        text: System.prettyName || System.name || "Operating system"
                        font.bold: true
                        font.pixelSize: 23
                        color: Appearance.colors.m3on_surface
                        elide: Text.ElideRight
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: (System.version || System.kernelVersion || "") || "Version"
                        font.pixelSize: 14
                        color: Appearance.colors.m3on_surface_variant
                        elide: Text.ElideRight
                    }
                }

                StyledRectangle {
                    Layout.preferredWidth: hostnameText.implicitWidth + 24
                    Layout.preferredHeight: 32
                    radius: Appearance.rounding.medium
                    color: Appearance.colors.m3secondary_container

                    StyledText {
                        id: hostnameText
                        anchors.centerIn: parent
                        text: (System.hostname || "Unknown")
                        font.family: "JetBrainsMono"
                        font.pixelSize: 12
                        color: Appearance.colors.m3on_secondary_container
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            SectionHeading {
                title: "Hardware"
                icon: "developer_board"
            }

            ClippingRectangle {
                Layout.fillWidth: true
                implicitHeight: hardwareLayout.implicitHeight
                radius: Appearance.rounding.extraLarge
                color: 'transparent'

                ColumnLayout {
                    id: hardwareLayout
                    anchors.fill: parent
                    spacing: 5

                    HardwareItem {
                        Layout.fillWidth: true
                        label: "Processor"
                        value: System.cpuModel || "Unknown"
                        icon: "memory"
                    }

                    HardwareItem {
                        Layout.fillWidth: true
                        label: "Graphics"
                        value: System.gpuModel || "Unknown"
                        icon: "developer_board"
                    }

                    HardwareItem {
                        Layout.fillWidth: true
                        label: "Installed Memory"
                        value: System.totalRam > 0
                            ? Utils.formatSize(System.totalRam)
                            : "Detecting..."
                        icon: "memory_alt"
                    }

                    HardwareItem {
                        Layout.fillWidth: true
                        label: "Display"
                        value: Quickshell.screens.length > 0
                            ? Quickshell.screens[0].width + " × " +
                            Quickshell.screens[0].height
                            : "Unknown"
                        icon: "monitor"
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            SectionHeading {
                title: "Resources"
                icon: "monitor_heart"
            }
            
            ClippingRectangle {
                Layout.fillWidth: true
                height: resourceGrid.height
                radius: Appearance.rounding.extraLarge
                color: 'transparent'
                GridLayout {
                    id: resourceGrid
                    width: parent.width
                    anchors.centerIn: parent
                    columns: 2
                    columnSpacing: 5
                    rowSpacing: 5

                    ResourceCard {
                        label: "Processor"
                        icon: "memory"
                        value: Math.round(System.cpuUsage) + "%"
                        detail: System.cpuTemperature > 0
                            ? "Temperature · " + System.cpuTemperature.toFixed(0) + " °C"
                            : "CPU utilization"
                        progress: System.cpuUsage
                    }

                    ResourceCard {
                        label: "Memory"
                        icon: "memory_alt"
                        value: Math.round(System.memoryUsage) + "%"
                        detail: Utils.formatSize(System.totalRam * System.memoryUsage / 100)
                            + " of " + Utils.formatSize(System.totalRam) + " used"
                        progress: System.memoryUsage
                    }

                    ResourceCard {
                        label: "Storage"
                        icon: "database"
                        value: Math.round(System.diskUsage) + "%"
                        detail: Utils.formatSize(System.diskUsed)
                            + " of " + Utils.formatSize(System.diskSize) + " used"
                        progress: System.diskUsage
                    }

                    ResourceCard {
                        visible: System.swapSize > 0
                        label: "Swap"
                        icon: "swap_horiz"
                        value: Math.round(System.swapUsagePercent) + "%"
                        detail: Utils.formatSize(System.swapUsage)
                            + " of " + Utils.formatSize(System.swapSize) + " used"
                        progress: System.swapUsagePercent
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12

            SectionHeading {
                title: "Activity"
                icon: "monitoring"
            }

            StyledRectangle {
                Layout.fillWidth: true
                implicitHeight: activityLayout.implicitHeight + 32
                radius: Appearance.rounding.extraLarge
                color: Appearance.colors.m3surface_container

                RowLayout {
                    id: activityLayout
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 12

                    ActivityItem {
                        Layout.fillWidth: true
                        label: "Uptime"
                        value: Utils.formatSeconds(System.uptime)
                        icon: "schedule"
                    }

                    StyledRectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        color: Colors.opacify(Appearance.colors.m3on_surface, 0.12)
                    }

                    ActivityItem {
                        Layout.fillWidth: true
                        label: "Download"
                        value: Utils.formatSize(System.networkDownloadSpeed) + "/s"
                        icon: "south"
                    }

                    StyledRectangle {
                        Layout.preferredWidth: 1
                        Layout.fillHeight: true
                        color: Colors.opacify(Appearance.colors.m3on_surface, 0.12)
                    }

                    ActivityItem {
                        Layout.fillWidth: true
                        label: "Upload"
                        value: Utils.formatSize(System.networkUploadSpeed) + "/s"
                        icon: "north"
                    }
                }
            }
        }
    }
}