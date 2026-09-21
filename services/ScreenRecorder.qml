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

    property bool fallbackUsed: false
    property bool recordingStarted: false
    property bool stopping: false

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
            if (running)
                return;

            if (root.stopping) {
                root.recordingStarted = false;
                return;
            }

            if (!root.isRecording)
                return;

            if (!root.recordingStarted && !root.fallbackUsed) {
                Log.warn("ScreenRecorder", "recording failed to start, falling back to portal");

                Whisker.notify("Whisker", "Failed to record screen, attempting to record via portal...")

                root.fallbackUsed = true;

                recorderProc.command = [
                    "sh",
                    "-c",
                    "gpu-screen-recorder -w portal -f " +
                    root.fps +
                    " -o " +
                    root.lastOutputFile
                ];

                recorderProc.running = true;

                Log.info("ScreenRecorder", "started portal fallback");
                return;
            }

            Log.info("ScreenRecorder", "process ended");

            root.isRecording = false;
            root.recordingStarted = false;
            timer.stop();
        }
    }

    Timer {
        id: startupTimer
        interval: 750
        repeat: false

        onTriggered: {
            if (!root.isRecording || root.stopping)
                return;

            if (recorderProc.running) {
                root.recordingStarted = true;
                timer.start();

                Log.info("ScreenRecorder", "recording process confirmed");
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

            if (hours > 0)
                root.elapsedTime = h + ":" + m + ":" + s;
            else
                root.elapsedTime = m + ":" + s;
        }
    }

    function start(screen) {
        if (screen == null) {
            console.error("Tried to start recording with no target screen to record.");
            return;
        }

        if (root.isRecording) {
            Log.warn("ScreenRecorder", "already recording");
            return;
        }

        var ts = Qt.formatDateTime(new Date(), "yyyy-MM-dd_hh-mm-ss");
        var filename = "Video_" + ts + ".mp4";

        root.lastOutputFile = root.outputDir + filename;
        root.fallbackUsed = false;
        root.recordingStarted = false;
        root.stopping = false;
        root.elapsedSeconds = 0;
        root.elapsedTime = "00:00";

        Quickshell.execDetached({
            command: ["mkdir", "-p", root.outputDir]
        });

        Log.info("ScreenRecorder", "init recording for object: " + screen);

        recorderProc.command = [
            "sh",
            "-c",
            "gpu-screen-recorder -w " +
            screen.name +
            " -f " +
            root.fps +
            " -o " +
            root.lastOutputFile
        ];

        recorderProc.running = true;
        root.isRecording = true;

        startupTimer.start();

        Log.info("ScreenRecorder", "started: " + filename);
    }

    function stop() {
        if (!root.isRecording) {
            Log.warn("ScreenRecorder", "not recording");
            return;
        }

        root.stopping = true;
        startupTimer.stop();
        timer.stop();

        recorderProc.running = false;

        root.isRecording = false;
        root.recordingStarted = false;

        Quickshell.execDetached({
            command: [
                "whisker",
                "notify",
                "Recording saved",
                "Saved as " + root.lastOutputFile
            ]
        });

        Log.info("ScreenRecorder", "stopped");
    }

    function toggle(screen) {
        if (root.isRecording)
            stop();
        else
            start(screen);
    }

    Component.onCompleted: {
        Log.info("ScreenRecorder", "initialized");
    }
}