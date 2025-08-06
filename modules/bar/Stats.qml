import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.components
import qs.modules
import qs.preferences

Item {
    id: root
    property real memoryValue: 0
    property real cpuValue: 0

    Layout.preferredWidth: container.implicitWidth
    Layout.preferredHeight: container.implicitHeight
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    RowLayout {
        id: container
        spacing: 10

        Item {
            id: cpuIndicator
            implicitWidth: 30
            implicitHeight: 30
            
            CircularProgress {
                anchors.fill: parent
                progress: root.cpuValue
                icon: "memory"
                strokeWidth: 2
            }
        }

        Item {
            id: memIndicator
            implicitWidth: 30
            implicitHeight: 30
            
            CircularProgress {
                anchors.fill: parent
                progress: root.memoryValue
                icon: "memory_alt"
                strokeWidth: 2
            }
        }
    }

    Process {
        id: memoryProc
        command: ["sh", "-c", "free | awk '/Mem:/ {printf(\"%.0f\", $3/$2 * 100)}'"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.memoryValue = parseFloat(this.text.trim())
        }
    }

    Process {
        id: cpuProc
        command: ["sh", "-c", "PREV=$(grep '^cpu ' /proc/stat); sleep 1; CURR=$(grep '^cpu ' /proc/stat); \
            PREV_TOTAL=$(echo $PREV | awk '{for(i=2;i<=NF;i++) total+=$i; print total}'); \
            PREV_IDLE=$(echo $PREV | awk '{print $5}'); \
            CURR_TOTAL=$(echo $CURR | awk '{for(i=2;i<=NF;i++) total+=$i; print total}'); \
            CURR_IDLE=$(echo $CURR | awk '{print $5}'); \
            DIFF_TOTAL=$((CURR_TOTAL - PREV_TOTAL)); DIFF_IDLE=$((CURR_IDLE - PREV_IDLE)); \
            echo $(( (100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL) ))"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.cpuValue = parseFloat(this.text.trim())
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            memoryProc.running = true
            cpuProc.running = true
        }
    }
}