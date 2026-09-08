import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.components
import qs.components.material
import qs.modules
import qs.services
import qs.preferences

Item {
    id: root
    property bool verticalMode: false

    Layout.preferredWidth: layoutLoader.item ? layoutLoader.item.implicitWidth : 0
    Layout.preferredHeight: layoutLoader.item ? layoutLoader.item.implicitHeight : 0
    implicitWidth: layoutLoader.item ? layoutLoader.item.implicitWidth : 0
    implicitHeight: layoutLoader.item ? layoutLoader.item.implicitHeight : 0

    Loader {
        id: layoutLoader
        anchors.fill: parent
        active: true
        sourceComponent: verticalMode ? columnLayoutComponent : rowLayoutComponent
    }

    Component {
        id: rowLayoutComponent
        RowLayout {
            spacing: 10

            Item {
                implicitWidth: 24
                implicitHeight: 24
                CircularProgress {
                    anchors.fill: parent
                    progress: System.cpuUsage
                    icon: "memory"
                    strokeWidth: 2
                }
            }

            Item {
                implicitWidth: 24
                implicitHeight: 24
                CircularProgress {
                    anchors.fill: parent
                    progress: System.memoryUsage
                    icon: "memory_alt"
                    strokeWidth: 2
                }
            }
        }
    }

    Component {
        id: columnLayoutComponent
        ColumnLayout {
            spacing: 10

            Item {
                implicitWidth: 30
                implicitHeight: 30
                CircularProgress {
                    anchors.fill: parent
                    progress: System.cpuUsage
                    icon: "memory"
                    strokeWidth: 2
                }
            }

            Item {
                implicitWidth: 30
                implicitHeight: 30
                CircularProgress {
                    anchors.fill: parent
                    progress: System.memoryUsage
                    icon: "memory_alt"
                    strokeWidth: 2
                }
            }
        }
    }

    HoverHandler {
        id: hover
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
    StyledPopout {
        id: popout
        hoverTarget:hover
        interactable: true
        hCenterOnItem: true
        requiresHover: false
        Component {
            Item {
                implicitWidth: 300
                implicitHeight: content.height + 10

                ColumnLayout {
                    id: content
                    anchors.centerIn: parent
                    width: parent.width - 10
                    spacing: 10
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10
                        StatEntry {
                            value: System.cpuUsage
                            icon: 'memory'
                            text: 'CPU'
                        }
                        StatEntry {
                            value: System.memoryUsage
                            icon: 'memory_alt'
                            text: 'Memory'
                            mainColor: Appearance.colors.m3secondary
                            secondaryColor: Appearance.colors.m3secondary_container
                        }
                        StatEntry {
                            value: (System.swapUsage / System.swapSize) * 100
                            icon: 'swap_horiz'
                            text: 'Swap'
                            mainColor: Appearance.colors.m3tertiary
                            secondaryColor: Appearance.colors.m3tertiary_container
                        }
                    }
                    StyledRectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.colors.m3surface_variant
                    }
                    InvertFilledProgress {
                        value: System.diskUsed
                        maxValue: System.diskSize
                        icon: "hard_drive"
                        text: "DISK (/)"
                        smallText: {Utils.formatSize(System.diskUsed) + " / " + Utils.formatSize(System.diskSize)}
                        mainColor: Appearance.colors.m3on_surface
                        secondaryColor: Appearance.colors.m3surface_container
                        tertiaryColor: Appearance.colors.m3surface_container_highest
                    }
                    StyledRectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.colors.m3surface_variant
                    }
                    StyledRectangle {
                        Layout.fillWidth: true
                        implicitHeight: 50
                        color: Appearance.colors.m3surface_container
                        radius: Appearance.rounding.medium

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            RowLayout {
                                Layout.alignment: Qt.AlignCenter
                                spacing: 6

                                MaterialIcon {
                                    icon: "device_thermostat"
                                    size: 20
                                    color: Appearance.colors.m3primary
                                }
                                ColumnLayout {
                                    spacing: 0
                                    StyledText {
                                        text: "CPU Temp"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.weight: 800
                                        font.pixelSize: 10
                                        color: Appearance.colors.m3primary
                                    }
                                    StyledText {
                                        text: System.cpuTemperature.toFixed(0) + "°C"
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                            }
                        }
                    }
                    StyledRectangle {
                        Layout.fillWidth: true
                        implicitHeight: 50
                        color: Appearance.colors.m3surface_container
                        radius: Appearance.rounding.medium

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6

                                MaterialIcon {
                                    icon: "arrow_upward"
                                    size: 20
                                    color: Appearance.colors.m3primary
                                }
                                ColumnLayout {
                                    spacing: 0
                                    StyledText {
                                        text: "Upload"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.weight: 800
                                        font.pixelSize: 10
                                        color: Appearance.colors.m3primary
                                    }
                                    StyledText {
                                        text: Utils.formatSize(System.networkUploadSpeed) + "/s"
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }

                            }

                            StyledRectangle {
                                Layout.fillHeight: true
                                width: 1
                                color: Appearance.colors.m3surface_variant
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.alignment: Qt.AlignVCenter
                                spacing: 6

                                MaterialIcon {
                                    icon: "arrow_downward"
                                    size: 20
                                    color: Appearance.colors.m3tertiary
                                }

                                ColumnLayout {
                                    spacing: 0
                                    StyledText {
                                        text: "Download"
                                        font.family: "JetBrainsMono Nerd Font"
                                        font.weight: 800
                                        font.pixelSize: 10
                                        color: Appearance.colors.m3tertiary
                                    }
                                    StyledText {
                                        text: Utils.formatSize(System.networkDownloadSpeed) + "/s"
                                        font.family: "JetBrainsMono Nerd Font"
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    component StatEntry: ColumnLayout {
        id: statEntry
        property real value: 0.0
        property string icon: ""
        property string text: ""
        property color mainColor: Appearance.colors.m3primary
        property color secondaryColor: Appearance.colors.m3primary_container
        spacing: 0
        M3CircularProgress {
            color: statEntry.mainColor
            backgroundColor: statEntry.secondaryColor
            implicitWidth: 60
            thickness: 4
            progress: statEntry.value / 100
            Behavior on progress {
                NumberAnimation {
                    duration: Appearance.animation.fast;
                    easing.type: Appearance.animation.easing
                }
            }
            MaterialIcon {
                icon: statEntry.icon
                color: statEntry.mainColor
                anchors.centerIn: parent
                size: 32
                opacity: !cpuMa.containsMouse
                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.fast;
                        easing.type: Appearance.animation.easing
                    }
                }
            }
            
            StyledText {
                anchors.centerIn: parent
                text: Math.round(statEntry.value) + "%"
                font.family: "Outfit SemiBold"
                color: statEntry.mainColor
                opacity: cpuMa.containsMouse
                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.fast;
                        easing.type: Appearance.animation.easing
                    }
                }
            }

            MouseArea {
                id: cpuMa
                hoverEnabled: true
                anchors.fill: parent
            }
        }
        StyledText {
            text: statEntry.text
            font.family: "Outfit ExtraBold"
            font.pixelSize: 16
            Layout.alignment: Qt.AlignHCenter
        }
    }
}
