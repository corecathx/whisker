import QtQuick
import QtQuick.Layouts
import qs.services
import qs.modules

Item {
    id: root
    width: content.implicitWidth + 40
    height: content.implicitHeight + 20
    visible: Lrclib.status === "FETCHING" || Lrclib.status === "LOADED"
    // Behavior on width { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
    // Behavior on height { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
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
            visible: Lrclib.status === "FETCHING"
        }

        StyledText {
            id: mainLyric
            visible: Lrclib.status === "LOADED" && text !== ""
            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 24
            font.family: "Outfit SemiBold"
            opacity: 0
        }

        StyledText {
            id: subLyric
            Layout.alignment: Qt.AlignHCenter
            color: Appearance.colors.m3on_surface_variant
            font.pixelSize: 16
            visible: Lrclib.status === "LOADED" && text !== ""
            opacity: 0
        }
    }

    Connections {
        target: Lrclib
        function onReady() {
            updateLyrics();
        }
        function onCurrentLineIndexChanged() {
            updateLyrics();
        }
    }

    Component.onCompleted: updateLyrics()

    function updateLyrics() {
        var idx = Lrclib.currentLineIndex;
        if (idx >= 0 && idx < Lrclib.lyricsData.length) {
            mainLyric.text = Lrclib.lyricsData[idx].text || "";
            subLyric.text = Lrclib.lyricsData[idx].translation || "";
            // fadeIn.restart();
            mainLyric.opacity = 1
            subLyric.opacity = 1
        } else {
            mainLyric.text = "";
            subLyric.text = "";
        }
    }

    ParallelAnimation {
        id: fadeIn
        NumberAnimation {
            target: mainLyric
            property: "opacity"
            from: 0
            to: 1
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
        NumberAnimation {
            target: subLyric
            property: "opacity"
            from: 0
            to: 1
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }
}
