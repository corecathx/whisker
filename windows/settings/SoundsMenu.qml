import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.preferences
import qs.components
import qs.modules
import qs.services

BaseMenu {
    title: "Sounds"
    description: "Adjust your audio devices and system volume."
    InfoCard {
        icon: "info"
        backgroundColor: Appearance.colors.m3primary
        contentColor: Appearance.colors.m3on_primary
        title: "Heads up!"
        description: "This menu is still being developed, so things might change overtime!"
    }
    BaseCard {
        StyledText {
            text: "Output Device"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }
        ExpandableCard {
            id: sinkList
            title: Audio.defaultSink.description
            description: Audio.defaultSink.name
            icon: "volume_up"
                Repeater {
                    model: {
                        return Audio.sinks
                    }
                    delegate: BaseRowCard {
                        verticalPadding: 20
                        cardMargin: 10

                        MaterialIcon {
                            id: icon
                            icon: "volume_up"
                            color: Appearance.colors.m3on_background
                            font.pixelSize: 32
                        }

                        ColumnLayout {
                            anchors.left: icon.right
                            anchors.leftMargin: 10
                            spacing: 0
                            StyledText {
                                text: modelData.description
                                font.pixelSize: 16
                                font.bold: true
                                color: Appearance.colors.m3on_background
                            }
                            StyledText {
                                text: modelData.name
                                font.pixelSize: 12
                                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Audio.setDefaultSink(modelData)
                                sinkList.expanded = false
                            }
                        }
                    }
                }
        }
        StyledText {
            text: "Volume"
            font.pixelSize: 16
            color: Appearance.colors.m3on_background
        }
        StyledSlider {
            id: vlmSlider
            value: Audio.volume * 100

            onValueChanged: {
                Audio.setVolume(value/100)
                if (value === 0) vlmSlider.icon = "volume_off";
                else if (value <= 50) vlmSlider.icon = "volume_down";
                else vlmSlider.icon = "volume_up";
            }
        }
        RowLayout {
            ColumnLayout {
                StyledText {
                    text: "Mute"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Whether to mute this device."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Audio.defaultSink.audio.muted
                onToggled: {
                    Audio.defaultSink.audio.muted = !Audio.defaultSink.audio.muted
                }
            }
        }
    }
    BaseCard {
        StyledText {
            text: "Input Device"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }
        StyledText {
            visible: Audio.sources.length == 0
            text: "No Input Devices found."
            font.pixelSize: 16
            anchors.horizontalCenter: parent.horizontalCenter
            color: Colors.opacify(Appearance.colors.m3on_background, 0.7)
        }
        ExpandableCard {
            visible: Audio.sources.length > 0
            id: sourceList
            title: Audio.defaultSource.description
            description: Audio.defaultSource.name
            icon: "mic"
                Repeater {
                    model: {
                        return Audio.sources
                    }
                    delegate: BaseRowCard {
                        verticalPadding: 20
                        cardMargin: 10

                        MaterialIcon {
                            id: iconInput
                            icon: "mic"
                            color: Appearance.colors.m3on_background
                            font.pixelSize: 32
                        }

                        ColumnLayout {
                            anchors.left: icon.right
                            anchors.leftMargin: 10
                            spacing: 0
                            StyledText {
                                text: modelData.description
                                font.pixelSize: 16
                                font.bold: true
                                color: Appearance.colors.m3on_background
                            }
                            StyledText {
                                text: modelData.name
                                font.pixelSize: 12
                                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                Audio.setDefaultSink(modelData)
                                sourceList.expanded = false
                            }
                        }
                    }
                }
        }
        StyledText {
            visible: Audio.sources.length > 0
            text: "Input Volume"
            font.pixelSize: 16
            color: Appearance.colors.m3on_background
        }
        StyledSlider {
            visible: Audio.sources.length > 0
            id: vlmSrcSlider
            value: Audio.defaultSource.audio.volume * 100

            onValueChanged: {
                Audio.setSourceVolume(value/100)
                if (value === 0) vlmSrcSlider.icon = "volume_off";
                else if (value <= 50) vlmSrcSlider.icon = "volume_down";
                else vlmSrcSlider.icon = "volume_up";
            }
        }
        RowLayout {
            visible: Audio.sources.length > 0
            ColumnLayout {
                StyledText {
                    text: "Mute"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: "Whether to mute this device."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Audio.defaultSource.audio.muted
                onToggled: {
                    Audio.defaultSource.audio.muted = !Audio.defaultSource.audio.muted
                }
            }
        }
    }
}
