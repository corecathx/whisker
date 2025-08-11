pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import qs.preferences

Singleton {
    id: root

    property int barCount: 100
    property list<int> values: Array(barCount)

    function onBarCountChanged() {
        root.values = Array(root.barCount);
        cavaProc.running = false;
        cavaProc.running = true;
    }
    
    Process {
        id: cavaProc
        command: ["sh", "-c", `printf '[general]\nframerate=18\nbars=${root.barCount}\nsleep_timer=3\n[output]\nchannels=mono\nmethod=raw\nraw_target=/dev/stdout\ndata_format=ascii\nascii_max_range=100\n[smoothing]\nnoise_reduction=10' | cava -p /dev/stdin`]
        stdout: SplitParser {
            onRead: data => {
                root.values = data.slice(0, -1).split(";").map(v => parseInt(v, 10));
            }
        }
    }

    function open() {

        console.log("Cava opened");
        cavaProc.running = true;
    }
    function close() {
        console.log("Cava closed");
        cavaProc.running = false;
    }

    Connections {
        target: Preferences

        function onCavaEnabledChanged() {
            console.log("Preferences changed!")
            if (Preferences.cavaEnabled)
                root.open()
            else
                root.close()
        }
    }
}