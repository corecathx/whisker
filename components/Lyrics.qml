import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import qs.providers
import qs.services
import qs.modules

Item {
    id: root
    property alias status: lyrics.status
    width: content.implicitWidth + 40
    height: content.implicitHeight + 20
    visible: (root.status === "FETCHING" || root.status === "LOADED")

    Behavior on width {
        NumberAnimation {
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
        }
    }

    LrclibProvider {
        id: lyrics
        currentArtist: Players.active?.trackArtist.replace(" - Topic", "") ?? ""
        currentTrack: Players.active?.trackTitle ?? ""
        currentPosition: (Players.active?.position ?? 0) * 1000
        Component.onCompleted: fetchLyrics()
    }

    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.m3surface
        radius: 20
    }

    ColumnLayout {
        id: content
        anchors.centerIn: parent

        LoadingIcon {
            Layout.alignment: Qt.AlignHCenter
            visible: lyrics.status === "FETCHING"
        }

        StyledText {
            id: mainLyric
            visible: lyrics.status === "LOADED" && text !== ""
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 24
            font.family: "Outfit SemiBold"
            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
        }

        StyledText {
            id: subLyric
            Layout.alignment: Qt.AlignHCenter
            color: Appearance.colors.m3on_surface_variant
            font.pixelSize: 16
            visible: lyrics.status === "LOADED" && text !== ""
            Behavior on opacity {
                NumberAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
        }
    }

    Connections {
        target: lyrics
        function onReady() {
            root.updateLyrics();
        }
        function onCurrentLineIndexChanged() {
            root.fadeOutAndUpdate();
        }
    }

    function updateLyrics() {
        const current = lyrics.currentLineIndex;
        mainLyric.text = lyrics.lyricsData[current]?.text || "";
        subLyric.text = lyrics.lyricsData[current]?.translation || "";
    }

    function fadeOutAndUpdate() {
        mainLyric.opacity = 0;
        subLyric.opacity = 0;
        updateTimer.restart();
    }

    Timer {
        id: updateTimer
        interval: Appearance.animation.fast
        onTriggered: {
            root.updateLyrics();
            Qt.callLater(() => {
                mainLyric.opacity = 1;
                subLyric.opacity = 1;
            });
        }
    }
}
