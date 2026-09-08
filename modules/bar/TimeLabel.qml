import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.modules
import qs.components
import qs.components.material
import qs.services

Item {
    id: root

    property bool showLabel: true
    property bool verticalMode: false
    property int padding: 8

    Layout.preferredWidth: verticalMode
        ? container.implicitWidth
        : showLabel
            ? container.implicitWidth
            : 0

    Layout.preferredHeight: verticalMode
        ? (showLabel ? container.implicitHeight : 0)
        : container.implicitHeight

    width: container.implicitWidth + (root.padding * 2)
    height: container.implicitHeight
    opacity: showLabel ? 1 : 0

    StyledRectangle {
        color: Appearance.colors.m3surface_container
        anchors.fill: parent
        radius: Appearance.rounding.large
    }

    Column {
        id: container
        spacing: verticalMode ? -2 : -5
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            spacing: -2
            anchors.horizontalCenter: verticalMode
                ? parent.horizontalCenter
                : undefined

            StyledText {
                text: verticalMode
                    ? Qt.formatDateTime(Time.date, "HH")
                    : Qt.formatDateTime(Time.date, "HH:mm")

                color: Appearance.colors.m3on_surface
                font.pixelSize: 18
                font.family: "Outfit ExtraBold"
                lineHeight: 0.1

                anchors.horizontalCenter: verticalMode
                    ? parent.horizontalCenter
                    : undefined
            }

            StyledText {
                visible: verticalMode

                text: Qt.formatDateTime(Time.date, "mm")

                color: Appearance.colors.m3on_surface
                font.pixelSize: 18
                font.family: "Outfit ExtraBold"
                font.bold: true
                lineHeight: 0.1

                anchors.horizontalCenter: verticalMode
                    ? parent.horizontalCenter
                    : undefined
            }
        }

        StyledText {
            text: verticalMode
                ? Qt.formatDateTime(Time.date, "dd/MM")
                : Qt.formatDateTime(Time.date, "ddd, dd/MM")

            color: Appearance.colors.m3on_surface_variant
            font.pixelSize: 12
            lineHeight: 0.1

            anchors.horizontalCenter: verticalMode
                ? parent.horizontalCenter
                : undefined
        }
    }

    Behavior on Layout.preferredWidth {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    Behavior on Layout.preferredHeight {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
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

        hoverTarget: hover
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

                    // Time
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 10

                        MaterialIcon {
                            size: 32
                            color: Appearance.colors.m3primary

                            icon: {
                                const hour = Time.hours

                                if (hour >= 5 && hour < 17)
                                    return "sunny"
                                else if (hour >= 17 && hour < 21)
                                    return "wb_twilight"
                                else
                                    return "dark_mode"
                            }
                        }

                        ColumnLayout {
                            spacing: 0

                            StyledText {
                                text: Qt.formatDateTime(
                                    Time.date,
                                    "HH:mm"
                                )

                                color: Appearance.colors.m3on_surface
                                font.pixelSize: 24
                                font.family: "Outfit ExtraBold"
                            }

                            StyledText {
                                text: Qt.formatDateTime(
                                    Time.date,
                                    "dddd, dd/MM/yyyy"
                                )

                                color: Appearance.colors.m3on_surface_variant
                                font.pixelSize: 14
                            }
                        }
                    }

                    StyledRectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.colors.m3surface_variant
                    }

                    // Weather
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        Item {
                            implicitWidth: 70
                            implicitHeight: 70

                            M3CircularProgress {
                                anchors.fill: parent

                                color: Appearance.colors.m3primary
                                backgroundColor: Appearance.colors.m3primary_container
                                thickness: 4

                                phaseMult: 0.1
                                amplitude: 2
                                progress: 1

                                MaterialIcon {
                                    anchors.centerIn: parent

                                    icon: Weather.icon
                                    size: 34
                                    color: Appearance.colors.m3primary
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            StyledText {
                                text: Math.round(Weather.temperature) + "°C"

                                color: Appearance.colors.m3on_surface
                                font.pixelSize: 28
                                font.family: "Outfit ExtraBold"
                            }

                            StyledText {
                                text: Weather.condition

                                color: Appearance.colors.m3on_surface_variant
                                font.pixelSize: 13
                            }

                            StyledText {
                                text: Weather.location

                                color: Appearance.colors.m3primary
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                font.weight: 700
                            }
                        }
                    }

                    // Weather stats
                    StyledRectangle {
                        Layout.fillWidth: true
                        implicitHeight: 50

                        color: Appearance.colors.m3surface_container
                        radius: Appearance.rounding.medium

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            WeatherStat {
                                icon: "thermostat"
                                text: "FEELS"
                                value: Math.round(
                                    Weather.apparentTemperature
                                ) + "°C"
                            }

                            StyledRectangle {
                                Layout.fillHeight: true
                                width: 1
                                color: Appearance.colors.m3surface_variant
                            }

                            WeatherStat {
                                icon: "humidity_percentage"
                                text: "HUMIDITY"
                                value: Math.round(
                                    Weather.humidity
                                ) + "%"
                                color: Appearance.colors.m3secondary
                            }

                            StyledRectangle {
                                Layout.fillHeight: true
                                width: 1
                                color: Appearance.colors.m3surface_variant
                            }

                            WeatherStat {
                                icon: "air"
                                text: "WIND"
                                value: Math.round(
                                    Weather.windSpeed
                                ) + " km/h"
                                color: Appearance.colors.m3tertiary
                            }
                        }
                    }

                    // AQI
                    InvertFilledProgress {
                        value: Weather.airQuality
                        maxValue: 300

                        icon: "air"
                        text: "AIR QUALITY"
                        smallText: Math.round(Weather.airQuality) + " AQI"

                        mainColor: Appearance.colors.m3on_surface
                        secondaryColor: Appearance.colors.m3surface_container
                        tertiaryColor: Appearance.colors.m3surface_container_highest
                    }

                    // Safety
                    StyledRectangle {
                        Layout.fillWidth: true
                        implicitHeight: 48

                        color: Weather.safeOutside
                            ? Appearance.colors.m3surface_container
                            : Appearance.colors.m3error_container

                        radius: Appearance.rounding.medium

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            MaterialIcon {
                                icon: Weather.safeOutside
                                    ? "check_circle"
                                    : "warning"

                                size: 24

                                color: Weather.safeOutside
                                    ? Appearance.colors.m3primary
                                    : Appearance.colors.m3on_error_container
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                StyledText {
                                    text: Weather.safeOutside
                                        ? "Good conditions"
                                        : "Be careful outside"

                                    font.family: "JetBrainsMono Nerd Font"
                                    font.weight: 800
                                    font.pixelSize: 12

                                    color: Weather.safeOutside
                                        ? Appearance.colors.m3on_surface
                                        : Appearance.colors.m3on_error_container
                                }

                                StyledText {
                                    visible: !Weather.safeOutside

                                    text: Weather.safetyReason

                                    font.family: "JetBrainsMono Nerd Font"
                                    font.pixelSize: 10

                                    color: Appearance.colors.m3on_error_container
                                }
                            }
                            Item { Layout.fillWidth: true }
                        }
                    }

                    StyledRectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.colors.m3surface_variant
                    }

                    Calendar {
                        Layout.fillWidth: true
                    }
                }

                component WeatherStat: RowLayout {
                    property string icon: ""
                    property string text: ""
                    property string value: ""
                    property color color: Appearance.colors.m3primary

                    Layout.fillWidth: true
                    spacing: 5

                    MaterialIcon {
                        icon: parent.icon
                        size: 18
                        color: parent.color
                    }

                    ColumnLayout {
                        spacing: 0
                        Layout.fillWidth: true

                        StyledText {
                            text: parent.parent.text

                            font.family: "JetBrainsMono Nerd Font"
                            font.weight: 800
                            font.pixelSize: 9

                            color: parent.parent.color
                        }

                        StyledText {
                            text: parent.parent.value

                            font.family: "JetBrainsMono Nerd Font"
                            font.pixelSize: 12

                            color: Appearance.colors.m3on_surface
                        }
                    }
                }
            }
        }
    }
}