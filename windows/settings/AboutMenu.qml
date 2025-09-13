import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Quickshell
import Quickshell.Widgets
import qs.modules
import qs.components

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
                    SpringAnimation {
                        spring: 5
                        damping: 0.15
                        mass: 0.5
                        epsilon: 0.01
                    }
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
                    text: "Whisker"
                    font.pixelSize: 20
                    font.bold: true
                    color: Appearance.colors.m3on_background
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 360
                }

                Text {
                    text: "A simple shell focusing on usability and customization."
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    color: Appearance.colors.m3on_background
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 360
                }

                Text {
                    text: "Cat sounds from Minecraft"
                    font.pixelSize: 10
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.5)
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 360
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                StyledButton {
                    text: "View on GitHub"
                    icon: 'code'
                    onClicked: Qt.openUrlExternally("https://github.com/corecathx/whisker")
                }
                StyledButton {
                    text: "Report Issue"
                    icon: "bug_report"
                    secondary: true
                    onClicked: Qt.openUrlExternally("https://github.com/corecathx/whisker/issues")
                }

            }

        }
    }
}
