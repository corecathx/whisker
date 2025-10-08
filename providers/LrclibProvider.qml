import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.services
import Quickshell.Services.Mpris

QtObject {
    id: root

    signal ready();

    // translation
    property string targetLanguage: "en"
    property bool enableTranslation: true

    // players
    property string currentTrack: Players.active.trackTitle ?? ""
    property string currentArtist: Players.active.trackArtist ?? ""
    property int currentPosition: Players.active.position * 1000
    property bool isPlaying: Players.active?.playbackState == MprisPlaybackState.Playing

    // states
    property var lyricsData: []
    property int currentLineIndex: -1
    readonly property string currentLine: (
        currentLineIndex >= 0 && currentLineIndex < lyricsData.length
            ? lyricsData[currentLineIndex].text
            : ""
    )

    // can only be one of these: "IDLE", "FETCHING", "LOADED", "ERROR", "NOT_FOUND"
    property string status: "IDLE"

    property string statusMessage: {
        switch (root.status) {
            case "IDLE":
                return "No track is playing";
            case "FETCHING":
                return "Fetching lyrics...";
            case "LOADED":
                return "Lyrics loaded";
            case "NOT_FOUND":
                return "Lyrics not found :(";
            default:
                if (root.status.startsWith("ERROR_")) {
                    let split = root.status.split("_")
                    return "Error: " + split[1]
                }
                return "Unknown";
        }
    }

    property Connections conns: Connections {
        target: Players.active
        function onPositionChanged() {
            root.currentPosition = Players.active.position * 1000;
            root.updateCurrentLine();
        }

        function onPostTrackChanged() {
            root.lyricsData = [];
            root.currentLineIndex = -1;
            fetchLyrics();
        }
    }

    property FrameAnimation frAnim: FrameAnimation {
        running: !!Players.active && root.isPlaying
        onTriggered: Players.active?.positionChanged()
    }

    function parseLRC(lrcText) {
        let lines = lrcText.split('\n');
        let parsed = [];
        for (let line of lines) {
            let match = line.match(/\[(\d+):(\d+)\.?(\d+)?\](.*)/);
            if (match) {
                let minutes = parseInt(match[1]);
                let seconds = parseInt(match[2]);
                let centiseconds = match[3] ? parseInt(match[3]) : 0;
                let time = (minutes * 60 + seconds) * 1000 + centiseconds * 10;
                let text = match[4].trim();
                if (text) {
                    parsed.push({ 
                        time: time, 
                        text: text, 
                        translation: "" 
                    });
                }
            }
        }
        
        parsed = parsed.sort((a, b) => a.time - b.time);
        
        if (enableTranslation) {
            for (let i = 0; i < parsed.length; i++)
                translateText(parsed[i].text, i);
        }
        
        return parsed;
    }

    function fetchLyrics() {
        if (currentArtist === "" || currentTrack === "") {
            root.status = "IDLE";
            lyricsData = [];
            currentLineIndex = -1;
            return;
        }
        root.status = "FETCHING";
        lyricsData = [];
        currentLineIndex = -1;

        let artist = encodeURIComponent(currentArtist);
        let track = encodeURIComponent(currentTrack);
        let url = `https://lrclib.net/api/get?artist_name=${artist}&track_name=${track}`;

        let xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText);
                    if (response.syncedLyrics) {
                        lyricsData = parseLRC(response.syncedLyrics)
                        root.ready()
                        root.status = `LOADED`;
                    } else {
                        root.status = "NOT_FOUND";
                    }
                } else {
                    root.status = `ERROR_${xhr.status}`;
                }
            }
        };
        xhr.send();
    }

    function updateCurrentLine() {
        if (lyricsData.length === 0)
            return;

        for (let i = lyricsData.length - 1; i >= 0; i--) {
            if (currentPosition >= lyricsData[i].time) {
                if (currentLineIndex !== i) {
                    currentLineIndex = i;
                }
                break;
            }
        }
    }
    
    function translateText(text, index) {
        if (!enableTranslation) return;
        
        let url = `https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=${targetLanguage}&dt=t&q=${encodeURIComponent(text)}`;
        let xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                try {
                    let response = JSON.parse(xhr.responseText);
                    if (response[0] && response[0][0]) {
                        let translated = response[0][0][0];
                        if (translated.toLowerCase().trim() !== text.toLowerCase().trim()) {
                            lyricsData[index].translation = translated;
                            lyricsDataChanged();
                        }
                    }
                } catch (e) {
                    console.log("Translation error:", e);
                }
            }
        };
        xhr.send();
    }
}