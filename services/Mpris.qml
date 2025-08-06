pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// lol
Singleton {
    id: root
    readonly property list<MprisPlayer> players: Mpris.players.values
    readonly property MprisPlayer active: players[0] ?? null
}