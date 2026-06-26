import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Io
import Quickshell.Widgets
import qs.components
import qs.components.players
import qs.modules
import qs.services

Item {
    id: root
    clip: true
    property string title: Players.active?.trackTitle ?? ""
    property string artist: Players.active?.trackArtist ?? ""
    property string icon: Players.active?.isPlaying ? "pause" : "play_arrow"

    width: contentRow.width + Math.abs(contentRow.height - height) * 4
    Behavior on width { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }

    implicitHeight: 25
    visible: !!Players.active && !!Players.active?.trackTitle

    ClippingRectangle {
        anchors.fill: parent
        radius: 20
        color: Appearance.colors.m3surface_container

        Image {
            opacity: mArea.containsMouse ? 0.6 : 0.4
            Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast * 0.5; } }
            asynchronous: true
            source: Players.active?.trackArtUrl ?? ""
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: 32
            }
        }
    }
    RowLayout {
        id: contentRow
        anchors {
            left: parent.left
            top: parent.top
            leftMargin: (root.width - width) / 2
            topMargin: (root.height - height) / 2
        }

        Item {
            Layout.alignment: Qt.AlignCenter
            implicitWidth: 22
            implicitHeight: 22

            CircularProgress {
                id: progCirc
                anchors.fill: parent
                icon: root.icon
                strokeWidth: 2
                useAnim: false
                allowViewingPercentage: false
                property real lastTime: Date.now();
                progress: (Players.active?.position / Players.active?.length) * 100
                Connections {
                    target: Players.active
                    function onPositionChanged() {
                        if (Date.now() - progCirc.lastTime > 1000) {
                            progCirc.lastTime = Date.now()
                            progCirc.progress = (Players.active?.position / Players.active?.length) * 100
                        }
                        //console.log(barSlider.value)
                    }

                    function onPostTrackChanged() {
                        progCirc.progress = 0
                        Players.active.position = 0 // BRUH
                    }
                }
            }
        }

        ColumnLayout {
            spacing: 0
            StyledText {
                Layout.alignment: Qt.AlignVCenter
                color: Appearance.colors.m3on_background
                font.pixelSize: 10
                font.family: "Outfit SemiBold"
                text: Utils.truncateText(root.title, 50)
            }

            StyledText {
                Layout.alignment: Qt.AlignVCenter
                color: Appearance.colors.m3on_background
                font.pixelSize: 8
                text: Utils.truncateText(root.artist, 50)
            }
        }
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
    HoverHandler {
        id: hover
    }
    StyledPopout {
        id: popout
        hoverTarget: hover
        interactable: true
        hCenterOnItem: true
        requiresHover: false
        Component {
            PlayerPopup {}
        }
    }
}
