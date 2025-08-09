import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Quickshell
import Quickshell.Widgets
import qs.modules

Item {
    anchors.fill: parent
    
    SoundEffect { id: cat0; source: Utils.getPath("audios/mc-cat0.wav"); volume: 0.8 }
    SoundEffect { id: cat1; source: Utils.getPath("audios/mc-cat1.wav"); volume: 0.8 }
    SoundEffect { id: cat2; source: Utils.getPath("audios/mc-cat2.wav"); volume: 0.8 }
    SoundEffect { id: cat3; source: Utils.getPath("audios/mc-cat3.wav"); volume: 0.8 }

    property var meowSounds: [cat0, cat1, cat2, cat3]

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 24

        ColumnLayout {
            spacing: 12
            Layout.alignment: Qt.AlignHCenter

            Image {
                id: whiskerIcon
                source: Appearance.whiskerIcon
                sourceSize: Qt.size(160, 160)
                fillMode: Image.PreserveAspectFit
                smooth: true
                Layout.alignment: Qt.AlignHCenter
                scale: 1.0

                Behavior on scale {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: whiskerIcon.scale = 1.1
                    onExited: whiskerIcon.scale = 1.0

                    onPressed: whiskerIcon.scale = 0.95
                    onReleased: whiskerIcon.scale = 1.1

                    onClicked: {
                        let index = Math.floor(Math.random() * meowSounds.length)
                        meowSounds[index].play()
                    }
                }
            }

            ColumnLayout {
                spacing: 10
                Layout.alignment: Qt.AlignHCenter

                Text {
                    text: "Whisker Shell v0.1"
                    font.pixelSize: 20
                    font.bold: true
                    color: Appearance.colors.m3on_background
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 320
                }

                Text {
                    text: "A simple shell focusing on usability."
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    color: Appearance.colors.m3on_background
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 320
                }

                Text {
                    text: "Cat sounds from Minecraft"
                    font.pixelSize: 10
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.5)
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 320
                }
            }
        }
    }
}
