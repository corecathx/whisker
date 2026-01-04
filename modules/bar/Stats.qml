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
    property bool verticalMode: false

    Layout.preferredWidth: layoutLoader.item ? layoutLoader.item.implicitWidth : 0
    Layout.preferredHeight: layoutLoader.item ? layoutLoader.item.implicitHeight : 0
    implicitWidth: layoutLoader.item ? layoutLoader.item.implicitWidth : 0
    implicitHeight: layoutLoader.item ? layoutLoader.item.implicitHeight : 0

    Loader {
        id: layoutLoader
        anchors.fill: parent
        active: true
        sourceComponent: verticalMode ? columnLayoutComponent : rowLayoutComponent
    }

    Component {
        id: rowLayoutComponent
        RowLayout {
            spacing: 10

            Item {
                implicitWidth: 24
                implicitHeight: 24
                CircularProgress {
                    anchors.fill: parent
                    progress: root.cpuValue
                    icon: "memory"
                    strokeWidth: 2
                }
            }

            Item {
                implicitWidth: 24
                implicitHeight: 24
                CircularProgress {
                    anchors.fill: parent
                    progress: root.memoryValue
                    icon: "memory_alt"
                    strokeWidth: 2
                }
            }
        }
    }

    Component {
        id: columnLayoutComponent
        ColumnLayout {
            spacing: 10

            Item {
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
    }

    Process {
        id: memoryProc
        command: ["sh", "-c", "free | awk '/Mem:/ {printf(\"%.0f\", $3/$2 * 100)}'"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.memoryValue = parseFloat(this.text.trim()) }
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
        stdout: StdioCollector { onStreamFinished: root.cpuValue = parseFloat(this.text.trim()) }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true
        onTriggered: {
            memoryProc.running = true
            cpuProc.running = true
        }
    }
}
