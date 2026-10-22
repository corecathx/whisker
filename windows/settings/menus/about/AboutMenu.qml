import QtQuick
import QtQuick.Layouts

import QtMultimedia
import Quickshell
import Quickshell.Widgets

import qs.modules
import qs.components
import qs.components.animation
import qs.preferences
import qs.services

import qs.windows.settings.menus.about.components

BaseMenu {
    title: "About"
    description: "Learn more about Whisker."

    SoundEffect { id: cat0; source: Utils.getPath("audios/mc-cat0.wav"); volume: 0.8 }
    SoundEffect { id: cat1; source: Utils.getPath("audios/mc-cat1.wav"); volume: 0.8 }
    SoundEffect { id: cat2; source: Utils.getPath("audios/mc-cat2.wav"); volume: 0.8 }
    SoundEffect { id: cat3; source: Utils.getPath("audios/mc-cat3.wav"); volume: 0.8 }

    property var meowSounds: [cat0, cat1, cat2, cat3]

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 20

        StyledRectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 180
            color: Appearance.colors.m3surface_container_high
            radius: Appearance.rounding.extraLarge

            RowLayout {
                anchors.fill: parent
                anchors{
                    margins: 30
                    topMargin: 10
                    bottomMargin: 10
                }
                spacing: 28

                Image {
                    id: whiskerIcon
                    Layout.preferredWidth: 136
                    Layout.preferredHeight: 136
                    source: Appearance.whiskerIcon
                    sourceSize: Qt.size(272, 272)
                    fillMode: Image.PreserveAspectFit
                    smooth: true

                    Behavior on scale {
                        SpringAnimation {
                            spring: 5
                            damping: 0.2
                            mass: 0.5
                            epsilon: 0.01
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: whiskerIcon.scale = 1.06
                        onExited: whiskerIcon.scale = 1
                        onPressed: whiskerIcon.scale = 0.94
                        onReleased: whiskerIcon.scale = containsMouse ? 1.06 : 1
                        onClicked: {
                            meowSounds[Math.floor(Math.random() * meowSounds.length)].play()
                            Whisker.setPrefs("misc.clickerCount", Preferences.misc.clickerCount + 1)
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    StyledText {
                        text: "Whisker"
                        font.family: "Outfit ExtraBold"
                        font.pixelSize: 32
                        color: Appearance.colors.m3on_surface
                    }

                    StyledText {
                        Layout.fillWidth: true
                        text: "A Desktop Shell for Hyprland, prioritizing usability (and cats)."
                        font.pixelSize: 15
                        color: Appearance.colors.m3on_surface_variant
                        wrapMode: Text.WordWrap
                    }

                    StyledRectangle {
                        Layout.preferredWidth: versionLabel.implicitWidth + 20
                        Layout.preferredHeight: 28
                        radius: Appearance.rounding.small
                        color: Appearance.colors.m3secondary_container

                        StyledText {
                            id: versionLabel
                            anchors.centerIn: parent
                            text: Whisker.version + " (" + Whisker.commit + ")"
                            font.pixelSize: 12
                            font.family: "JetBrainsMono"
                            color: Appearance.colors.m3on_secondary_container
                        }
                    }
                }
                ColumnLayout {
                    StyledButton {
                        Layout.preferredHeight: 32
                        icon: "code"
                        onClicked: Qt.openUrlExternally("https://github.com/corecathx/whisker")
                    }

                    StyledButton {
                        Layout.preferredHeight: 32
                        icon: "bug_report"
                        secondary: true
                        onClicked: Qt.openUrlExternally("https://github.com/corecathx/whisker/issues")
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8

            StyledText {
                text: "Project"
                font.family: "Outfit SemiBold"
                font.pixelSize: 18
                color: Appearance.colors.m3on_surface
            }

            StyledRectangle {
                Layout.fillWidth: true
                implicitHeight: projectInfo.implicitHeight + 32
                color: Appearance.colors.m3surface_container
                radius: Appearance.rounding.medium

                RowLayout {
                    id: projectInfo
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 14

                    StyledRectangle {
                        Layout.preferredWidth: 42
                        Layout.preferredHeight: 42
                        radius: Appearance.rounding.medium
                        color: Appearance.colors.m3surface_container_high

                        Image {
                            anchors.centerIn: parent
                            sourceSize: Qt.size(22, 22)
                            source: Utils.getPath('images/icons/quickshell.svg')
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 3

                        StyledText {
                            text: "Built on Quickshell"
                            font.pixelSize: 15
                            font.bold: true
                            color: Appearance.colors.m3on_surface
                        }

                        StyledText {
                            Layout.fillWidth: true
                            text: "A toolkit for building status bars, widgets, lockscreens, and other desktop components using QtQuick."
                            font.pixelSize: 13
                            wrapMode: Text.WordWrap
                            color: Appearance.colors.m3on_surface_variant
                        }
                    }

                    StyledButton {
                        text: "Website"
                        secondary: true
                        onClicked: Qt.openUrlExternally("https://quickshell.org")
                    }
                }
            }
        }
        ColumnLayout {
            id: updatesLayout

            property bool expanded: false

            Layout.fillWidth: true
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                StyledText {
                    Layout.fillWidth: true
                    text: "Updates"
                    font.family: "Outfit SemiBold"
                    font.pixelSize: 18
                    color: Appearance.colors.m3on_surface
                }
                StyledText {
                    text: Whisker.updates.length + " update(s) found"
                    color: Appearance.colors.m3on_surface_variant
                }

            }

            ClippingRectangle {
                Layout.fillWidth: true
                implicitHeight: updateList.implicitHeight
                Anim on implicitHeight {

                }
                color: 'transparent'
                radius: Appearance.rounding.extraLarge
                ColumnLayout {
                    id: updateList
                    width: parent.width
                    spacing: 5

                    Repeater {
                        model: {
                            return updatesLayout.expanded
                            ? Whisker.updates
                            : Whisker.updates.slice(0, 3)
                        }

                        delegate: UpdateItem {
                            Layout.fillWidth: true
                            height: 70
                        }
                    }
                }

            }


            StyledButton {
                visible: Whisker.updates.length > 3
                text: updatesLayout.expanded ? "Show less" : "Show all"
                secondary: true
                Layout.alignment: Qt.AlignHCenter

                onClicked: updatesLayout.expanded = !updatesLayout.expanded
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: "Cat sounds from Minecraft"
            font.pixelSize: 11
            color: Colors.opacify(Appearance.colors.m3on_surface, 0.5)
            horizontalAlignment: Text.AlignHCenter
        }
    }
}