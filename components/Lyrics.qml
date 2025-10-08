import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.providers
import qs.services
import qs.modules

BaseCard {
    id: root
    property bool hideOnNoLyrics: false
    LrclibProvider {
        id: lyrics
        currentArtist: Players.active?.trackArtist
        currentTrack: Players.active?.trackTitle
        Component.onCompleted: fetchLyrics()
    }

    Text {
        color: Appearance.colors.m3on_surface
        text: lyrics.status !== "LOADED" ? lyrics.statusMessage : ""
        visible: lyrics.status !== "LOADED"
        anchors.centerIn: parent
    }

    ListView {
        id: lyricsView
        anchors.margins: 40
        model: lyrics.lyricsData
        clip: true
        spacing: 8
        interactive: false
        boundsBehavior: Flickable.StopAtBounds
        currentIndex: lyrics.currentLineIndex

        Layout.fillWidth: true
        property int visibleLines: 10
        implicitHeight: (20 + spacing) * visibleLines

        preferredHighlightBegin: height / 2 - 20
        preferredHighlightEnd: height / 2 + 20
        highlightMoveDuration: 300
        highlightMoveVelocity: -1
        highlightRangeMode: ListView.StrictlyEnforceRange
        highlightFollowsCurrentItem: true

        delegate: Item {
            id: delegateRoot
            width: ListView.view.width
            implicitHeight: col.implicitHeight
            z: ListView.isCurrentItem ? 10 : 0

            property int distanceFromCurrent: index - lyrics.currentLineIndex
            property real calculatedOpacity: {
                switch (Math.abs(distanceFromCurrent)) {
                    case 0: return 1.0
                    case 1: return 0.4
                    case 2: return 0.1
                    default: return 0
                }
            }

            Rectangle {
                id: elevationBg
                anchors.centerIn: col
                width: col.width + 32
                height: col.height + 16
                radius: 12
                color: Appearance.colors.m3surface_container_high
                opacity: ListView.isCurrentItem ? 1 : 0
                scale: ListView.isCurrentItem ? 1 : 0.95

                Behavior on opacity { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
                Behavior on scale { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }

                layer.enabled: ListView.isCurrentItem
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowBlur: 0.8
                    shadowOpacity: 0.3
                    shadowVerticalOffset: 4
                    shadowHorizontalOffset: 0
                    shadowColor: "#000000"
                }
            }

            Column {
                id: col
                width: parent.width
                spacing: 4

                Text {
                    id: mainLyrics
                    text: modelData.text
                    font.bold: ListView.isCurrentItem
                    font.pixelSize: ListView.isCurrentItem ? 26 : 20
                    color: Appearance.colors.m3on_surface
                    opacity: delegateRoot.calculatedOpacity
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap

                    Behavior on font.pixelSize { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
                    Behavior on opacity { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
                }

                Text {
                    id: translatedLyrics
                    text: modelData.translation
                    visible: text !== ""
                    font.bold: ListView.isCurrentItem
                    font.pixelSize: ListView.isCurrentItem ? 20 : 14
                    color: Appearance.colors.m3on_surface
                    opacity: delegateRoot.calculatedOpacity * 0.5
                    width: parent.width
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap

                    Behavior on font.pixelSize { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
                    Behavior on opacity { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
                }
            }
        }

        Connections {
            target: lyrics
            function onCurrentLineIndexChanged() {
                lyricsView.currentIndex = lyrics.currentLineIndex
            }
            function onReady() {
                lyricsView.currentIndex = lyrics.currentLineIndex
            }
        }
    }
}