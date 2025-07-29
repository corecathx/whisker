import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.components
import qs.modules

Item {
    id: root
    property string memory: "..."
    property string icon: "memory_alt"

    property string cpu: "0%"
    property string icon_cpu: "memory"

    Layout.preferredWidth: width
    Layout.preferredHeight: height
    width: container.implicitWidth
    height: container.implicitHeight
    RowLayout {
        spacing: 10;
        RowLayout {
            id:container2;
            spacing: 5;
            
            MaterialSymbol {
                font.pixelSize: 20
                icon: root.icon_cpu
                color: Colors.foreground
            }
            Text {
                text: root.cpu
                color: Colors.foreground
                font.pixelSize: 12
            }
        }
        RowLayout {
            id:container;
            spacing: 5;
            
            MaterialSymbol {
                font.pixelSize: 20
                icon: root.icon
                color: Colors.foreground
            }
            Text {
                id: memoryLabel
                text: root.memory
                color: Colors.foreground
                font.pixelSize: 12
            }
        }
    }


    Process {
        id: memoryProc
        command: ["sh", "-c", "free | awk '/Mem:/ {printf(\"%.0f%%\", $3/$2 * 100)}'"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.memory = this.text.trim()
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
            echo $(( (100 * (DIFF_TOTAL - DIFF_IDLE) / DIFF_TOTAL) ))%"]


        running: true

        stdout: StdioCollector {
            onStreamFinished: root.cpu = this.text.trim()
        }
    }

    Timer {
        interval: 10000
        running: true
        repeat: true
        onTriggered: ()=>{
            memoryProc.running = true
            cpuProc.running = true;
        }
    }
}
