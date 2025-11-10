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
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.95

    Behavior on opacity {
        NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
    }
    Behavior on scale {
        NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing }
    }

    SoundEffect { id: cat0; source: Utils.getPath("audios/mc-cat0.wav"); volume: 0.8 }
    SoundEffect { id: cat1; source: Utils.getPath("audios/mc-cat1.wav"); volume: 0.8 }
    SoundEffect { id: cat2; source: Utils.getPath("audios/mc-cat2.wav"); volume: 0.8 }
    SoundEffect { id: cat3; source: Utils.getPath("audios/mc-cat3.wav"); volume: 0.8 }

    property var meowSounds: [cat0, cat1, cat2, cat3]

    ColumnLayout {
        anchors.centerIn: parent

        ColumnLayout {
            spacing: 10
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
                        damping: 0.1
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

                StyledText {
                    text: "Whisker"
                    font.pixelSize: 24
                    font.family: "Outfit ExtraBold"
                    color: Appearance.colors.m3on_background
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 400
                }

                StyledText {
                    text: "A simple shell focusing on usability and customization (and cats)."
                    font.pixelSize: 14
                    wrapMode: Text.Wrap
                    color: Appearance.colors.m3on_background
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 400
                }
            }
            Item {}
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 10

                StyledButton {
                    text: "View on GitHub"
                    icon: 'code'
                    onClicked: Qt.openUrlExternally("https://github.com/corecathx/whisker")
                    topRightRadius: 5
                    bottomRightRadius: 5
                }
                StyledButton {
                    text: "Report Issue"
                    icon: "bug_report"
                    secondary: true
                    onClicked: Qt.openUrlExternally("https://github.com/corecathx/whisker/issues")
                    topLeftRadius: 5
                    bottomLeftRadius: 5
                }

            }
        }
    }

    StyledText {
        text: "Cat sounds from Minecraft"
        font.pixelSize: 12
        color: Colors.opacify(Appearance.colors.m3on_background, 0.5)
        anchors.bottom: parent.bottom;
        anchors.bottomMargin: 40;
        anchors.horizontalCenter: parent.horizontalCenter
    }
    StyledText {
        text: "Built on top of <a href='https://quickshell.org'>Quickshell</a>"
        font.pixelSize: 12
        color: Colors.opacify(Appearance.colors.m3on_background, 0.5)
        textFormat: Text.RichText
        horizontalAlignment: Text.AlignHCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 60
        anchors.horizontalCenter: parent.horizontalCenter
        onLinkActivated: Qt.openUrlExternally(link)
    }

}
