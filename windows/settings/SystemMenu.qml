import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.preferences
import qs.components
import qs.modules

BaseMenu {
    id: root
    title: "System"
    description: "Detailed overview of your system"

    property string hostname: ""
    property string kernel: ""
    property string os: ""
    property string uptime: ""
    property string cpuModel: ""
    property int cpuCores: 0
    property string cpuUsage: "0"
    property real cpuTemp: 0
    property string cpuFreq: ""
    property string memTotal: ""
    property string memUsed: ""
    property string memAvail: ""
    property string memUsage: "0"
    property string swapTotal: ""
    property string swapUsed: ""
    property string swapUsage: "0"
    property string diskTotal: ""
    property string diskUsed: ""
    property string diskUsage: "0"
    property string gpuInfo: ""
    property string gpuDriver: ""
    property string displayServer: ""
    property int screenCount: Quickshell.screens.length
    property string resolution: ""
    property string shell: ""
    property string de: ""
    property string wm: ""
    property string architecture: ""
    property int totalProcesses: 0
    property string loadAverage: ""
    property string batteryPercent: ""

    Component.onCompleted: {
        hostnameProc.running = true
        kernelProc.running = true
        osProc.running = true
        uptimeProc.running = true
        cpuModelProc.running = true
        cpuCoresProc.running = true
        cpuFreqProc.running = true
        cpuUsageProc.running = true
        cpuTempProc.running = true
        memProc.running = true
        swapProc.running = true
        diskProc.running = true
        gpuProc.running = true
        gpuDriverProc.running = true
        displayServerProc.running = true
        shellProc.running = true
        deProc.running = true
        wmProc.running = true
        archProc.running = true
        processCountProc.running = true
        loadAvgProc.running = true
        batteryProc.running = true
        updateResolution()
    }

    function updateResolution() {
        if (Quickshell.screens.length > 0) {
            const screen = Quickshell.screens[0]
            root.resolution = screen.width + "x" + screen.height
        }
    }

    Process {
        id: hostnameProc
        command: ["hostnamectl", '--static']
        stdout: StdioCollector {
            onStreamFinished: root.hostname = text.trim()
        }
    }

    Process {
        id: kernelProc
        command: ["uname", "-r"]
        stdout: StdioCollector {
            onStreamFinished: root.kernel = text.trim()
        }
    }

    Process {
        id: osProc
        command: ["sh", "-c", "cat /etc/os-release | grep PRETTY_NAME | cut -d'\"' -f2"]
        stdout: StdioCollector {
            onStreamFinished: root.os = text.trim()
        }
    }

    Process {
        id: archProc
        command: ["uname", "-m"]
        stdout: StdioCollector {
            onStreamFinished: root.architecture = text.trim()
        }
    }

    Process {
        id: uptimeProc
        command: ["sh", "-c", "uptime -p | sed 's/up //'"]
        stdout: StdioCollector {
            onStreamFinished: root.uptime = text.trim()
        }
    }

    Process {
        id: cpuModelProc
        command: ["sh", "-c", "cat /proc/cpuinfo | grep 'model name' | head -n1 | cut -d':' -f2 | xargs"]
        stdout: StdioCollector {
            onStreamFinished: root.cpuModel = text.trim()
        }
    }

    Process {
        id: cpuCoresProc
        command: ["nproc"]
        stdout: StdioCollector {
            onStreamFinished: root.cpuCores = parseInt(text.trim())
        }
    }

    Process {
        id: cpuFreqProc
        command: ["sh", "-c", "cat /proc/cpuinfo | grep 'cpu MHz' | head -n1 | awk '{print $4}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const mhz = parseFloat(text.trim())
                root.cpuFreq = (mhz / 1000).toFixed(2) + " GHz"
            }
        }
    }

    Process {
        id: cpuUsageProc
        command: ["sh", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1"]
        stdout: StdioCollector {
            onStreamFinished: root.cpuUsage = text.trim()
        }
    }

    Process {
        id: cpuTempProc
        command: ["sh", "-c", "sensors 2>/dev/null | grep -i 'Package id 0:\\|Tctl:' | awk '{print $3}' | tr -d '+°C' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: {
                const temp = text.trim()
                root.cpuTemp = temp ? parseFloat(temp) : 0
            }
        }
    }

    Process {
        id: loadAvgProc
        command: ["sh", "-c", "uptime | awk -F'load average:' '{print $2}' | xargs"]
        stdout: StdioCollector {
            onStreamFinished: root.loadAverage = text.trim()
        }
    }

    Process {
        id: processCountProc
        command: ["sh", "-c", "ps aux | wc -l"]
        stdout: StdioCollector {
            onStreamFinished: root.totalProcesses = parseInt(text.trim()) - 1
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            cpuUsageProc.running = true
            cpuFreqProc.running = true
            cpuTempProc.running = true
            memProc.running = true
            loadAvgProc.running = true
            processCountProc.running = true
            batteryProc.running = true
        }
    }

    Process {
        id: memProc
        command: ["sh", "-c", "free -h | awk '/Mem:/ {print $2 \"|\" $3 \"|\" $7 \"|\" int($3/$2*100)}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length === 4) {
                    root.memTotal = parts[0]
                    root.memUsed = parts[1]
                    root.memAvail = parts[2]
                    root.memUsage = parts[3]
                }
            }
        }
    }

    Process {
        id: swapProc
        command: ["sh", "-c", "free -b | awk '/Swap:/ {if ($2 != 0) printf(\"%.1fGiB|%.1fGiB|%d\", $2/1073741824, $3/1073741824, int($3/$2*100)); else print \"0|0|0\"}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length === 3) {
                    root.swapTotal = parts[0]
                    root.swapUsed = parts[1]
                    root.swapUsage = parts[2]
                }
            }
        }
    }

    Process {
        id: diskProc
        command: ["sh", "-c", "df -h / | awk 'NR==2 {print $2 \"|\" $3 \"|\" $5}'"]
        stdout: StdioCollector {
            onStreamFinished: {
                const parts = text.trim().split("|")
                if (parts.length === 3) {
                    root.diskTotal = parts[0]
                    root.diskUsed = parts[1]
                    root.diskUsage = parts[2].replace("%", "")
                }
            }
        }
    }

    Process {
        id: gpuProc
        command: ["sh", "-c", "lspci | grep -i 'vga\\|3d\\|display' | cut -d':' -f3 | xargs"]
        stdout: StdioCollector {
            onStreamFinished: root.gpuInfo = text.trim()
        }
    }

    Process {
        id: gpuDriverProc
        command: ["sh", "-c", "lspci -k | grep -A 3 -i 'vga\\|3d\\|display' | grep 'Kernel driver' | awk '{print $5}' | head -n1"]
        stdout: StdioCollector {
            onStreamFinished: root.gpuDriver = text.trim()
        }
    }

    Process {
        id: displayServerProc
        command: ["sh", "-c", "echo $XDG_SESSION_TYPE"]
        stdout: StdioCollector {
            onStreamFinished: {
                const type = text.trim().toLowerCase()
                root.displayServer = type.charAt(0).toUpperCase() + type.slice(1)
            }
        }
    }

    Process {
        id: shellProc
        command: ["sh", "-c", "echo $SHELL | rev | cut -d'/' -f1 | rev"]
        stdout: StdioCollector {
            onStreamFinished: root.shell = text.trim()
        }
    }

    Process {
        id: deProc
        command: ["sh", "-c", "echo $XDG_CURRENT_DESKTOP"]
        stdout: StdioCollector {
            onStreamFinished: root.de = text.trim() || "None"
        }
    }

    Process {
        id: wmProc
        command: ["sh", "-c", "echo $HYPRLAND_INSTANCE_SIGNATURE"]
        stdout: StdioCollector {
            onStreamFinished: root.wm = text.trim() ? "Hyprland" : "Unknown"
        }
    }

    Process {
        id: batteryProc
        command: ["sh", "-c", "if [ -d /sys/class/power_supply/BAT* ]; then cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1; fi"]
        stdout: StdioCollector {
            onStreamFinished: {
                const percent = text.trim()
                root.batteryPercent = percent ? percent + "%" : ""
            }
        }
    }

    BaseCard {
        RowLayout {
            spacing: 10

            MaterialIcon {
                icon: "info"
                color: Appearance.colors.m3primary
                font.pixelSize: 20
            }

            StyledText {
                text: "System Details"
                font.pixelSize: 18
                font.bold: true
                color: Appearance.colors.m3on_background
            }
        }

        GridLayout {
            columns: 2
            rowSpacing: 15
            columnSpacing: 20
            Layout.fillWidth: true

            DetailItem {
                label: "Hostname"
                value: root.hostname || "Loading..."
                icon: "computer"
            }

            DetailItem {
                label: "Operating System"
                value: root.os || "Loading..."
                icon: "dns"
            }

            DetailItem {
                label: "Kernel"
                value: root.kernel || "Loading..."
                icon: "settings_system_daydream"
            }

            DetailItem {
                label: "Architecture"
                value: root.architecture || "Loading..."
                icon: "architecture"
            }

            DetailItem {
                label: "Uptime"
                value: root.uptime || "Loading..."
                icon: "schedule"
            }

            DetailItem {
                label: "Shell"
                value: root.shell || "Loading..."
                icon: "terminal"
            }

            DetailItem {
                label: "Window Manager"
                value: root.wm || "Loading..."
                icon: "window"
            }

            DetailItem {
                label: "Processes"
                value: root.totalProcesses > 0 ? root.totalProcesses.toString() : "Loading..."
                icon: "memory"
            }
        }
    }

    BaseCard {
        cardSpacing: 10
        RowLayout {
            spacing: 10

            MaterialIcon {
                icon: "developer_board"
                color: Appearance.colors.m3primary
                font.pixelSize: 20
            }

            StyledText {
                text: "Hardware"
                font.pixelSize: 18
                font.bold: true
                color: Appearance.colors.m3on_background
            }
        }

        HardwareItem {
            icon: "memory"
            label: "Processor"
            value: root.cpuModel || "Loading..."
            detail: root.cpuCores > 0 ? (root.cpuCores + " cores • " + root.cpuFreq) : ""
            detail2: root.cpuTemp > 0 ? (root.cpuTemp.toFixed(1) + "°C") : ""
            warning: root.cpuTemp > 75
        }

        HardwareItem {
            icon: "videocam"
            label: "Graphics"
            value: root.gpuInfo || "Loading..."
            detail: root.gpuDriver ? ("Driver: " + root.gpuDriver) : ""
        }

        HardwareItem {
            icon: "desktop_windows"
            label: "Display Server"
            value: root.displayServer || "Loading..."
            detail: root.screenCount + " screen" + (root.screenCount > 1 ? "s" : "")
        }

        HardwareItem {
            icon: "aspect_ratio"
            label: "Primary Resolution"
            value: root.resolution || "Loading..."
        }
    }

    BaseCard {
        cardSpacing: 10
        RowLayout {
            spacing: 10

            MaterialIcon {
                icon: "analytics"
                color: Appearance.colors.m3primary
                font.pixelSize: 20
            }

            StyledText {
                text: "Performance"
                font.pixelSize: 18
                font.bold: true
                color: Appearance.colors.m3on_background
            }
        }

        PerformanceItem {
            label: "CPU Usage"
            value: root.cpuUsage + "%"
            progress: parseFloat(root.cpuUsage) / 100
            icon: "speed"
        }

        PerformanceItem {
            label: "Memory"
            value: root.memUsed + " / " + root.memTotal
            detail: root.memUsage + "%"
            progress: parseFloat(root.memUsage) / 100
            icon: "memory"
        }

        PerformanceItem {
            visible: root.swapTotal !== "0" && root.swapTotal !== ""
            label: "Swap"
            value: root.swapUsed + " / " + root.swapTotal
            detail: root.swapUsage + "%"
            progress: parseFloat(root.swapUsage) / 100
            icon: "swap_horiz"
        }

        PerformanceItem {
            label: "Disk Usage (Root)"
            value: root.diskUsed + " / " + root.diskTotal
            detail: root.diskUsage + "%"
            progress: parseFloat(root.diskUsage) / 100
            icon: "storage"
        }
    }

    component DetailItem: ColumnLayout {
        required property string label
        required property string value
        required property string icon

        spacing: 0
        Layout.fillWidth: true

        RowLayout {
            spacing: 10

            MaterialIcon {
                icon: parent.parent.icon
                color: Appearance.colors.m3primary
                font.pixelSize: 20
            }

            StyledText {
                text: parent.parent.label
                font.pixelSize: 12
                color: Colors.opacify(Appearance.colors.m3on_background, 0.7)
            }
        }

        StyledText {
            text: value
            font.pixelSize: 14
            font.bold: true
            color: Appearance.colors.m3on_background
            Layout.leftMargin: 30
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    component HardwareItem: BaseRowCard {
        id: base
        required property string label
        required property string value
        required property string icon
        property string detail: ""
        property string detail2: ""
        property bool warning: false

        cardSpacing: 0
        verticalPadding: 0
        cardMargin: 0

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 10
            color: Colors.opacify(Appearance.colors.m3primary, 0.15)

            MaterialIcon {
                anchors.centerIn: parent
                icon: base.icon
                color: Appearance.colors.m3primary
                font.pixelSize: 20
            }
        }

        ColumnLayout {
            spacing: 0
            Layout.leftMargin: 10
            Layout.fillWidth: true

            StyledText {
                text: label
                font.pixelSize: 12
                color: Colors.opacify(Appearance.colors.m3on_background, 0.7)
            }

            StyledText {
                text: value
                font.pixelSize: 14
                font.bold: true
                color: Appearance.colors.m3on_background
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            RowLayout {
                spacing: 10
                visible: detail !== "" || detail2 !== ""

                StyledText {
                    visible: detail !== ""
                    text: detail
                    font.pixelSize: 10
                    color: Appearance.colors.m3primary
                }

                StyledText {
                    visible: detail2 !== ""
                    text: detail2
                    font.pixelSize: 10
                    color: warning ? Appearance.colors.m3error : Appearance.colors.m3primary
                }
            }
        }
    }

    component PerformanceItem: BaseRowCard {
        required property string label
        required property string value
        property string detail: ""
        required property real progress
        required property string icon

        cardSpacing: 0
        verticalPadding: 10
        cardMargin: 0

        MaterialIcon {
            icon: parent.icon
            color: Appearance.colors.m3primary
            font.pixelSize: 20
        }

        ColumnLayout {
            spacing: 5
            Layout.leftMargin: 10
            Layout.fillWidth: true

            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                ColumnLayout {
                    spacing: 0

                    StyledText {
                        text: label
                        font.pixelSize: 12
                        color: Colors.opacify(Appearance.colors.m3on_background, 0.7)
                    }

                    StyledText {
                        text: value
                        font.pixelSize: 14
                        font.bold: true
                        color: Appearance.colors.m3on_background
                    }
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    visible: detail !== ""
                    text: detail
                    font.pixelSize: 14
                    font.bold: true
                    color: {
                        const p = parseFloat(detail)
                        return p > 85 ? Appearance.colors.m3error :
                               p > 70 ? "#FFA500" :
                               Appearance.colors.m3primary
                    }
                }
            }

            StyledProgressBar {
                fill: Math.min(progress, 1.0)
                height: 10
            }
        }
    }
}
