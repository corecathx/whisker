pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io

Singleton {
    id: privacy

    readonly property bool hasAnyActiveAccess:
        hasCameraAccess || hasMicrophoneAccess || hasScreenCaptureAccess

    readonly property bool hasMicrophoneAccess: (
        Pipewire.linkGroups.values
        .some(pwlg => pwlg.source.type === PwNodeType.AudioSource &&
                      pwlg.target.type === PwNodeType.AudioInStream)
    )

    readonly property list<PwNode> screenCaptureApps: (
        Pipewire.linkGroups.values
        .filter(pwlg => pwlg.source.type === PwNodeType.VideoSource)
        .map(pwlg => pwlg.target)
    )

    readonly property bool hasScreenCaptureAccess:
        screenCaptureApps.length > 0

    property var cameraApps: []
    readonly property bool hasCameraAccess: cameraApps.length > 0

    Process {
        id: pwMonitor
        running: true
        command: ["pw-mon", "--color=never"]

        stdout: SplitParser {
            onRead: updateTimer.restart()
        }
    }

    Timer {
        id: updateTimer
        interval: 150
        repeat: false
        onTriggered: refresh()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: refresh()
    }

    function refresh() {
        cameraScan.running = false
        cameraScan.running = true
    }

    Process {
        id: cameraScan
        command: ["sh", "-c", `
            cam=$(lsof /dev/video* 2>/dev/null \
                | awk 'NR>1 {print $1}' | sort -u | tr '\\n' ',')
            echo "\${cam%,}"
        `]

        stdout: SplitParser {
            onRead: data => {
                privacy.cameraApps =
                    data.trim().split(',').filter(Boolean)
            }
        }
    }
}
