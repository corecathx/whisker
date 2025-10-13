import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Io
import qs.components
import qs.modules
import qs.services

Item {
    id: root

    property string title: Players.active?.trackTitle ?? ""
    property string icon: Players.active?.isPlaying ? "pause" : "play_arrow"

    width: contentRow.width
    implicitHeight: contentRow.implicitHeight
    visible: Players.active

    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    RowLayout {
        id: contentRow

        MouseArea {
            Layout.fillWidth: true
            Layout.fillHeight: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (!Players.active)
                    return;

                Players.active.isPlaying = !Players.active.isPlaying
            }
        }
        Item {
            implicitWidth: 30
            implicitHeight: 30
            CircularProgress {
                id: progCirc
                anchors.fill: parent
                icon: root.icon
                strokeWidth: 2
                useAnim: false
                allowViewingPercentage: false
                property real lastTime: Date.now();
                progress: (Players.active.position / Players.active.length) * 100
                Connections {
                    target: Players.active
                    function onPositionChanged() {
                        if (Date.now() - progCirc.lastTime > 1000) {
                            progCirc.lastTime = Date.now()
                            progCirc.progress = (Players.active.position / Players.active.length) * 100
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

        StyledText {
            Layout.alignment: Qt.AlignVCenter
            color: Appearance.colors.m3on_background
            font.pixelSize: 12
            text: Utils.truncateText(root.title, 20)
        }
    }
    HoverHandler {
        id: hover
    }
    StyledPopout {
        hoverTarget: hover
        interactable: true
        hCenterOnItem: true
        Component {
            PlayerDisplay {
                artSize: 55
                titleSize: 14
                artistSize: 10
                iconSize: 46
                sliderHeight: 10
                spacing: 20
            }
        }
    }
}
