import QtQuick
import Quickshell.Services.Pipewire
import qs.components

ProgressOsd {
    id: root

    property real volume: Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume * 100

    label: "Volume"
    valueText: Pipewire.defaultAudioSink?.audio.muted ? 'Muted' : Math.floor(volume)
    fillValue: Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume
    iconName: volume > 50 ? "volume_up" : volume > 0 ? "volume_down" : "volume_off"

    PwObjectTracker {
        objects: [ Pipewire.defaultAudioSink ]
    }

    Connections {
        target: Pipewire.defaultAudioSink?.audio ?? null

        function onVolumeChanged() {
            root.show()
        }

        function onMutedChanged() {
            root.show()
        }
    }
}
