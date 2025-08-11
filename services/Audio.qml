pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import qs.modules
import qs.preferences

Singleton {
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

    property PwNode defaultSink: Pipewire.defaultAudioSink
    property real volume: defaultSink?.audio?.volume ?? 0
    property bool muted: defaultSink?.audio?.muted ?? false

    function setVolume(to: real): void {
        if (defaultSink?.ready && defaultSink?.audio) {
            defaultSink.audio.muted = false;
            defaultSink.audio.volume = Math.max(0, Math.min(1, to));
        }
    }
}
