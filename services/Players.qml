pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// lol
Singleton {
    id: root
    readonly property list<MprisPlayer> players: Mpris.players.values
    readonly property MprisPlayer active: players[0] ?? null
    readonly property bool isPlaying: Players.active?.playbackState == MprisPlaybackState.Playing

    property Timer posTimer: Timer {
        interval: 250
        repeat: true
        running: !!root.active && root.isPlaying
        onTriggered: {
            if (Players.active) {
                Players.active.positionChanged()
            }
        }
    }
}
