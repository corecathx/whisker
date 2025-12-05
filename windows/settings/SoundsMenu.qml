import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.preferences
import qs.components
import qs.modules
import qs.services

BaseMenu {
    title: "Sound"
    description: "Volume and audio devices"

    InfoCard {
        icon: "info"
        title: "Preview"
        description: "This panel is in active development"
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: Appearance.colors.m3primary_container

                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: "volume_up"
                        color: Appearance.colors.m3on_primary_container
                        font.pixelSize: 24
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Output"
                        font.pixelSize: 16
                        font.family: "Outfit Medium"
                        color: Appearance.colors.m3on_surface
                    }

                    StyledText {
                        text: Audio.defaultSink.description
                        font.pixelSize: 13
                        color: Appearance.colors.m3on_surface_variant
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.colors.m3outline_variant
                opacity: 0.4
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Volume"
                        font.pixelSize: 14
                        font.family: "Outfit Medium"
                        color: Appearance.colors.m3on_surface
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: Math.round(outputVolumeSlider.value) + "%"
                        font.pixelSize: 14
                        font.family: "Outfit SemiBold"
                        color: Appearance.colors.m3primary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    MaterialIcon {
                        icon: outputVolumeSlider.value === 0 ? "volume_off" : outputVolumeSlider.value < 33 ? "volume_mute" : outputVolumeSlider.value < 66 ? "volume_down" : "volume_up"
                        color: Appearance.colors.m3on_surface_variant
                        font.pixelSize: 24
                    }

                    StyledSlider {
                        id: outputVolumeSlider
                        Layout.fillWidth: true
                        value: Audio.volume * 100
                        onValueChanged: {
                            Audio.setVolume(value / 100);
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    text: "Device"
                    font.pixelSize: 14
                    font.family: "Outfit Medium"
                    color: Appearance.colors.m3on_surface
                }

                StyledDropDown {
                    Layout.fillWidth: true
                    label: "Output device"
                    model: Audio.sinks.map(sink => sink.description)
                    currentIndex: {
                        for (let i = 0; i < Audio.sinks.length; i++) {
                            if (Audio.sinks[i].name === Audio.defaultSink.name) {
                                return i;
                            }
                        }
                        return -1;
                    }
                    onSelectedIndexChanged: index => {
                        if (index >= 0 && index < Audio.sinks.length) {
                            Audio.setDefaultSink(Audio.sinks[index]);
                        }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 12
                color: Appearance.colors.m3surface_container_high

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    MaterialIcon {
                        icon: Audio.defaultSink.audio.muted ? "volume_off" : "volume_up"
                        color: Audio.defaultSink.audio.muted ? Appearance.colors.m3error : Appearance.colors.m3on_surface_variant
                        font.pixelSize: 24
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Mute output"
                        font.pixelSize: 14
                        color: Appearance.colors.m3on_surface
                    }

                    StyledSwitch {
                        checked: Audio.defaultSink.audio.muted
                        onToggled: {
                            Audio.defaultSink.audio.muted = !Audio.defaultSink.audio.muted;
                        }
                    }
                }
            }
        }
    }

    BaseCard {
        ColumnLayout {
            width: parent.width
            spacing: 20

            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 40
                    Layout.preferredHeight: 40
                    radius: 20
                    color: Appearance.colors.m3secondary_container

                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: "mic"
                        color: Appearance.colors.m3on_secondary_container
                        font.pixelSize: 24
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    StyledText {
                        text: "Input"
                        font.pixelSize: 16
                        font.family: "Outfit Medium"
                        color: Appearance.colors.m3on_surface
                    }

                    StyledText {
                        visible: Audio.sources.length > 0
                        text: Audio.sources.length > 0 ? Audio.defaultSource.description : ""
                        font.pixelSize: 13
                        color: Appearance.colors.m3on_surface_variant
                    }
                }
            }

            Rectangle {
                visible: Audio.sources.length === 0
                Layout.fillWidth: true
                Layout.preferredHeight: 120
                radius: 12
                color: Appearance.colors.m3surface_container_high

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8

                    MaterialIcon {
                        icon: "mic_off"
                        font.pixelSize: 48
                        color: Colors.opacify(Appearance.colors.m3on_surface, 0.3)
                        Layout.alignment: Qt.AlignHCenter
                    }

                    StyledText {
                        text: "No input devices"
                        font.pixelSize: 14
                        font.family: "Outfit Medium"
                        color: Appearance.colors.m3on_surface_variant
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }

            Rectangle {
                visible: Audio.sources.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Appearance.colors.m3outline_variant
                opacity: 0.4
            }

            ColumnLayout {
                visible: Audio.sources.length > 0
                Layout.fillWidth: true
                spacing: 12

                RowLayout {
                    Layout.fillWidth: true

                    StyledText {
                        text: "Volume"
                        font.pixelSize: 14
                        font.family: "Outfit Medium"
                        color: Appearance.colors.m3on_surface
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    StyledText {
                        text: Math.round(inputVolumeSlider.value) + "%"
                        font.pixelSize: 14
                        font.family: "Outfit SemiBold"
                        color: Appearance.colors.m3primary
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 16

                    MaterialIcon {
                        icon: inputVolumeSlider.value === 0 ? "mic_off" : "mic"
                        color: Appearance.colors.m3on_surface_variant
                        font.pixelSize: 24
                    }

                    StyledSlider {
                        id: inputVolumeSlider
                        Layout.fillWidth: true
                        value: Audio.sources.length > 0 ? Audio.defaultSource.audio.volume * 100 : 0
                        onValueChanged: {
                            Audio.setSourceVolume(value / 100);
                        }
                    }
                }
            }

            ColumnLayout {
                visible: Audio.sources.length > 0
                Layout.fillWidth: true
                spacing: 8

                StyledText {
                    text: "Device"
                    font.pixelSize: 14
                    font.family: "Outfit Medium"
                    color: Appearance.colors.m3on_surface
                }

                StyledDropDown {
                    Layout.fillWidth: true
                    label: "Input device"
                    model: Audio.sources.map(source => source.description)
                    currentIndex: {
                        for (let i = 0; i < Audio.sources.length; i++) {
                            if (Audio.sources[i].name === Audio.defaultSource.name) {
                                return i;
                            }
                        }
                        return -1;
                    }
                    onSelectedIndexChanged: index => {
                        if (index >= 0 && index < Audio.sources.length) {
                            Audio.setDefaultSource(Audio.sources[index]);
                        }
                    }
                }
            }

            Rectangle {
                visible: Audio.sources.length > 0
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                radius: 12
                color: Appearance.colors.m3surface_container_high

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    spacing: 12

                    MaterialIcon {
                        icon: Audio.defaultSource.audio.muted ? "mic_off" : "mic"
                        color: Audio.defaultSource.audio.muted ? Appearance.colors.m3error : Appearance.colors.m3on_surface_variant
                        font.pixelSize: 24
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "Mute input"
                        font.pixelSize: 14
                        color: Appearance.colors.m3on_surface
                    }

                    StyledSwitch {
                        checked: Audio.defaultSource.audio.muted
                        onToggled: {
                            Audio.defaultSource.audio.muted = !Audio.defaultSource.audio.muted;
                        }
                    }
                }
            }
        }
    }
}
