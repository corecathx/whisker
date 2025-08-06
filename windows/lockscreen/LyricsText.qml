import QtQuick
import Quickshell
import Quickshell.Io

Text {
    id: lyricsText
    text: "Loading lyrics..."
    font.pixelSize: 20
    wrapMode: Text.Wrap
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    property string track: "Just the Two of Us"

    Component.onCompleted: fetchLyrics()

    function fetchLyrics() {
        var url = "https://lrclib.net/api/search?q=" + encodeURIComponent(track)

        var proc = Process.create()
        proc.setProgram("curl")
        proc.setArguments([
            "-s",
            "-H", "User-Agent: CoreCatLyrics/0.1 (https://corecathx.github.io)",
            url
        ])
        proc.setShell(true)

        proc.finished.connect(function() {
            var output = proc.stdout.trim()
            if (output === "[]" || output === "") {
                lyricsText.text = "No lyrics found."
                return
            }

            try {
                var results = JSON.parse(output)
                if (results.length > 0) {
                    var item = results[0]
                    if (item.syncedLyrics)
                        lyricsText.text = item.syncedLyrics
                    else if (item.plainLyrics)
                        lyricsText.text = item.plainLyrics
                    else
                        lyricsText.text = "Lyrics found, but empty."
                } else {
                    lyricsText.text = "Lyrics not found."
                }
            } catch (e) {
                lyricsText.text = "Failed to parse lyrics."
            }
        })

        proc.start()
    }
}
