pragma Singleton
import Quickshell
import Quickshell.Io
import QtQuick
import qs.modules

Singleton {
    id: root

    property string lastOutputFile: ""
    property string outputDir: Quickshell.env("HOME") + "/Videos/screenrecords/"
    property int fps: 60
    property bool isRecording: false
    property int elapsedSeconds: 0
    property string elapsedTime: "00:00"

    Process {
        id: recorderProc
        running: false

        stdout: SplitParser {
            onRead: data => Log.info("ScreenRecorder", data)
        }

        stderr: SplitParser {
            onRead: data => Log.warn("ScreenRecorder", data)
        }

        onRunningChanged: {
            if (!running && root.isRecording) {
                Log.info("ScreenRecorder", "process ended");
                root.isRecording = false;
                timer.stop();
            }
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: true
        onTriggered: {
            root.elapsedSeconds++;

            var hours = Math.floor(root.elapsedSeconds / 3600);
            var minutes = Math.floor((root.elapsedSeconds % 3600) / 60);
            var seconds = root.elapsedSeconds % 60;

            var h = hours.toString().padStart(2, '0');
            var m = minutes.toString().padStart(2, '0');
            var s = seconds.toString().padStart(2, '0');

            if (hours > 0) {
                root.elapsedTime = h + ":" + m + ":" + s;
            } else {
                root.elapsedTime = m + ":" + s;
            }
        }
    }

    function start() {
        if (root.isRecording) {
            Log.warn("ScreenRecorder", "already recording");
            return;
        }

        var ts = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
        var filename = "Video_" + ts + ".mp4";
        root.lastOutputFile = root.outputDir + filename;

        Quickshell.execDetached({
            command: ["mkdir", "-p", root.outputDir]
        });

        recorderProc.command = ["sh", "-c", "gpu-screen-recorder -w screen -f " + root.fps + " -o " + root.lastOutputFile];
        recorderProc.running = true;
        root.isRecording = true;
        root.elapsedSeconds = 0;
        root.elapsedTime = "00:00";
        timer.start();

        Log.info("ScreenRecorder", "started: " + filename);
    }

    function stop() {
        if (!root.isRecording) {
            Log.warn("ScreenRecorder", "not recording");
            return;
        }

        recorderProc.running = false;
        root.isRecording = false;
        timer.stop();
        Quickshell.execDetached({
            command: ["whisker", "notify", "Recording saved", "Saved as " + root.lastOutputFile]
        });
        Log.info("ScreenRecorder", "stopped");
    }

    function toggle() {
        if (root.isRecording) stop();
        else start();
    }

    Component.onCompleted: {
        Log.info("ScreenRecorder", "initialized");
    }
}
