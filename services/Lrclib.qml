pragma Singleton
import QtQuick
import QtQuick.Controls
import Quickshell
import qs.services
import qs.preferences
import Quickshell.Services.Mpris

Singleton {
    id: root

    signal ready

    property string targetLanguage: Preferences.misc.lyricsLanguage
    property bool enableTranslation: Preferences.misc.translateLyrics

    property string currentTrack: Players.active?.trackTitle ?? ""
    property string currentArtist: Players.active?.trackArtist.replace(" - Topic", "") ?? ""
    property int currentPosition: (Players.active?.position ?? 0) * 1000
    property bool isPlaying: Players.active?.playbackState == MprisPlaybackState.Playing

    property var lyricsData: []
    property int currentLineIndex: -1
    readonly property string currentLine: (currentLineIndex >= 0 && currentLineIndex < lyricsData.length ? lyricsData[currentLineIndex].text : "")

    property string status: "IDLE"

    property string statusMessage: {
        if (status == "IDLE") return "No track is playing";
        if (status == "FETCHING") return "Fetching lyrics...";
        if (status == "LOADED") return "Lyrics loaded";
        if (status == "NOT_FOUND") return "Lyrics not found :(";
        if (status.startsWith("ERROR_")) return "Error: " + status.split("_")[1];
        return "Unknown";
    }

    property Timer prefDebounceTimer: Timer {
        interval: 500
        repeat: false
        onTriggered: {
            if (currentArtist && currentTrack) fetchLyrics();
        }
    }

    onTargetLanguageChanged: {
        if (lyricsData.length > 0) prefDebounceTimer.restart();
    }

    onEnableTranslationChanged: {
        if (lyricsData.length > 0) prefDebounceTimer.restart();
    }

    property Connections conns: Connections {
        target: Players.active
        enabled: !!Players.active

        function onPositionChanged() {
            if (!Players.active) return;
            root.currentPosition = Players.active.position * 1000;
            updateCurrentLine();
        }

        function onPostTrackChanged() {
            lyricsData = [];
            currentLineIndex = -1;
            if (currentArtist && currentTrack) fetchLyrics();
        }
    }

    function parseLRC(lrcText) {
        var lines = lrcText.split('\n');
        var parsed = [];

        for (var i = 0; i < lines.length; i++) {
            var match = lines[i].match(/\[(\d+):(\d+)\.?(\d+)?\](.*)/);
            if (!match) continue;

            var mins = parseInt(match[1]);
            var secs = parseInt(match[2]);
            var cs = match[3] ? parseInt(match[3]) : 0;
            var text = match[4].trim();

            if (text) {
                parsed.push({
                    time: (mins * 60 + secs) * 1000 + cs * 10,
                    text: text,
                    translation: ""
                });
            }
        }

        parsed.sort(function(a, b) { return a.time - b.time; });

        if (enableTranslation && parsed.length > 0) {
            translateBatch(parsed);
        }

        return parsed;
    }

    function fetchLyrics() {
        if (!currentArtist || !currentTrack) {
            status = "IDLE";
            lyricsData = [];
            currentLineIndex = -1;
            return;
        }

        status = "FETCHING";
        lyricsData = [];
        currentLineIndex = -1;

        var url = "https://lrclib.net/api/get?artist_name=" + encodeURIComponent(currentArtist) + "&track_name=" + encodeURIComponent(currentTrack);
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url);
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) return;

            if (xhr.status === 200) {
                var resp = JSON.parse(xhr.responseText);
                if (resp.syncedLyrics) {
                    lyricsData = parseLRC(resp.syncedLyrics);
                    root.ready();
                    status = "LOADED";
                } else {
                    status = "NOT_FOUND";
                }
            } else {
                status = "ERROR_" + xhr.status;
            }
        };
        xhr.send();
    }

    function updateCurrentLine() {
        if (!lyricsData.length) return;

        for (var i = lyricsData.length - 1; i >= 0; i--) {
            if (currentPosition >= lyricsData[i].time) {
                if (currentLineIndex !== i) {
                    currentLineIndex = i;
                }
                return;
            }
        }
    }

    function translateBatch(lyrics) {
        if (!enableTranslation || !lyrics.length) return;

        var batchSize = 50;
        var batches = Math.ceil(lyrics.length / batchSize);
        var completedBatches = 0;

        for (var b = 0; b < batches; b++) {
            var start = b * batchSize;
            var end = Math.min(start + batchSize, lyrics.length);
            var lines = [];

            for (var i = start; i < end; i++) {
                lines.push(lyrics[i].text);
            }

            var combined = lines.join('\n');
            var url = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=" + targetLanguage + "&dt=t&q=" + encodeURIComponent(combined);

            (function(batchStart, totalBatches) {
                var xhr = new XMLHttpRequest();
                xhr.open("GET", url);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState !== XMLHttpRequest.DONE) return;
                    if (xhr.status !== 200) {
                        completedBatches++;
                        return;
                    }

                    try {
                        var resp = JSON.parse(xhr.responseText);
                        if (!resp[0]) {
                            completedBatches++;
                            return;
                        }

                        var translated = "";
                        for (var j = 0; j < resp[0].length; j++) {
                            translated += resp[0][j][0];
                        }

                        var translatedLines = translated.split('\n');
                        for (var k = 0; k < translatedLines.length; k++) {
                            var idx = batchStart + k;
                            if (idx >= lyricsData.length) break;

                            var tr = translatedLines[k].trim();
                            var orig = lyricsData[idx].text.trim();

                            if (tr.toLowerCase() !== orig.toLowerCase()) {
                                lyricsData[idx].translation = tr;
                            }
                        }

                        completedBatches++;
                        // Only signal once when all batches complete
                        if (completedBatches === totalBatches) {
                            lyricsDataChanged();
                        }
                    } catch (e) {
                        completedBatches++;
                    }
                };
                xhr.send();
            })(start, batches);
        }
    }

    Component.onCompleted: {
        if (currentArtist && currentTrack) fetchLyrics();
    }
}
