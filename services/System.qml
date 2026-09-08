pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: system

    // os
    property string name: ""
    property string version: ""
    property string prettyName: ""
    property string logo: ""
    property string id: ""
    property string qsVersion: ""

    // uptime
    property real uptime: 0

    // cpu
    property real cpuUsage: 0
    property real cpuTemperature: 0

    // memory
    property real memoryUsage: 0
    property real totalRam: 0

    // swap
    property real swapUsage: 0
    property real swapSize: 0
    property real swapUsagePercent: swapSize > 0
        ? swapUsage / swapSize * 100
        : 0

    // disk (/)
    property real diskSize: 0
    property real diskUsed: 0
    property real diskAvailable: 0
    property real diskUsage: diskSize > 0
        ? diskUsed / diskSize * 100
        : 0

    // network
    property real networkDownload: 0
    property real networkUpload: 0
    property real networkDownloadSpeed: 0
    property real networkUploadSpeed: 0

    Process {
        id: versionProcess

        running: true
        command: ["qs", "--version"]

        stdout: StdioCollector {
            onStreamFinished: {
                system.qsVersion = this.text
                    .trim()
                    .split(",")[0]
                    .trim()
                    .replace("quickshell ", "")
            }
        }
    }

    Process {
        id: osProcess

        running: true
        command: [
            "sh",
            "-c",
            "source /etc/os-release && echo \"$NAME|$VERSION|$PRETTY_NAME|$LOGO|$ID\""
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split("|")

                if (parts.length >= 5) {
                    system.name = parts[0]
                    system.version = parts[1]
                    system.prettyName = parts[2]
                    system.logo = parts[3]
                    system.id = parts[4]
                }
            }
        }
    }

    FileView {
        path: "/proc/uptime"
        watchChanges: true

        onFileChanged: {
            system.uptime = parseFloat(text().trim().split(" ")[0])
        }

        onLoaded: {
            system.uptime = parseFloat(text().trim().split(" ")[0])
        }
    }

    Process {
        id: cpuProcess

        command: [
            "sh",
            "-c",
            "PREV=$(grep '^cpu ' /proc/stat); " +
            "sleep 1; " +
            "CURR=$(grep '^cpu ' /proc/stat); " +

            "PREV_TOTAL=$(echo \"$PREV\" | awk '{for(i=2;i<=NF;i++) total+=$i; print total}'); " +
            "PREV_IDLE=$(echo \"$PREV\" | awk '{print $5+$6}'); " +

            "CURR_TOTAL=$(echo \"$CURR\" | awk '{for(i=2;i<=NF;i++) total+=$i; print total}'); " +
            "CURR_IDLE=$(echo \"$CURR\" | awk '{print $5+$6}'); " +

            "DIFF_TOTAL=$((CURR_TOTAL-PREV_TOTAL)); " +
            "DIFF_IDLE=$((CURR_IDLE-PREV_IDLE)); " +

            "if [ \"$DIFF_TOTAL\" -gt 0 ]; then " +
            "echo $((100*(DIFF_TOTAL-DIFF_IDLE)/DIFF_TOTAL)); " +
            "else echo 0; fi"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                system.cpuUsage = parseFloat(this.text.trim())
            }
        }
    }

    Process {
        id: temperatureProcess

        command: [
            "sensors",
            "-j"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(this.text)

                    const cpu = data["coretemp-isa-0000"]

                    if (cpu && cpu["Package id 0"]) {
                        const temperature =
                            cpu["Package id 0"]["temp1_input"]

                        if (temperature !== undefined)
                            system.cpuTemperature = temperature
                    }
                } catch (error) {
                    console.log("Failed to parse CPU temperature:", error)
                }
            }
        }
    }

    Process {
        id: memoryProcess

        command: [
            "sh",
            "-c",
            "free -b | awk '/Mem:/ {printf \"%s %s\\n\", $2, $2-$7}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/)

                if (parts.length >= 2) {
                    system.totalRam = parseFloat(parts[0])

                    system.memoryUsage =
                        parseFloat(parts[1]) / system.totalRam * 100
                }
            }
        }
    }

    Process {
        id: swapProcess

        command: [
            "sh",
            "-c",
            "free -b | awk '/Swap:/ {printf \"%s %s\\n\", $2, $3}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/)

                if (parts.length >= 2) {
                    system.swapSize = parseFloat(parts[0])
                    system.swapUsage = parseFloat(parts[1])
                }
            }
        }
    }

    Process {
        id: diskProcess

        command: [
            "sh",
            "-c",
            "df -B1 / | awk 'NR==2 {printf \"%s %s %s\\n\", $2, $3, $4}'"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/)

                if (parts.length >= 3) {
                    system.diskSize = parseFloat(parts[0])
                    system.diskUsed = parseFloat(parts[1])
                    system.diskAvailable = parseFloat(parts[2])
                }
            }
        }
    }

    Process {
        id: networkProcess

        property string interfaceName: ""
        property real lastDownload: 0
        property real lastUpload: 0

        command: [
            "sh",
            "-c",
            "iface=$(ip route show default | awk 'NR==1 {print $5}'); " +
            "rx=$(cat /sys/class/net/$iface/statistics/rx_bytes); " +
            "tx=$(cat /sys/class/net/$iface/statistics/tx_bytes); " +
            "echo \"$iface $rx $tx\""
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const parts = this.text.trim().split(/\s+/)

                if (parts.length >= 3) {
                    const rx = parseFloat(parts[1])
                    const tx = parseFloat(parts[2])

                    system.networkDownload = rx
                    system.networkUpload = tx

                    if (networkProcess.interfaceName === parts[0]) {
                        system.networkDownloadSpeed =
                            Math.max(0, (rx - networkProcess.lastDownload) / 3)

                        system.networkUploadSpeed =
                            Math.max(0, (tx - networkProcess.lastUpload) / 3)
                    }

                    networkProcess.interfaceName = parts[0]
                    networkProcess.lastDownload = rx
                    networkProcess.lastUpload = tx
                }
            }
        }
    }

    Timer {
        interval: 3000
        running: true
        repeat: true

        onTriggered: {
            cpuProcess.running = true
            temperatureProcess.running = true
            memoryProcess.running = true
            swapProcess.running = true
            diskProcess.running = true
            networkProcess.running = true
        }
    }

    Component.onCompleted: {
        cpuProcess.running = true
        temperatureProcess.running = true
        memoryProcess.running = true
        swapProcess.running = true
        diskProcess.running = true
        networkProcess.running = true
    }
}