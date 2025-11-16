import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.modules
import qs.services

Item {
    id: root
    width: content.width + 24
    height: content.height + 24

    property bool expanded: false
    property var frameLog: []
    property real fps: 0
    property real smoothFps: 0
    property int drops: 0
    property var fpsGraph: []
    property real lastFps: 0

    property real memRss: 0
    property var memGraph: []

    property real cpuPercent: 0
    property var cpuGraph: []
    property int threads: 0

    function lerp(a, b, t) {
        return a + (b - a) * t;
    }
    function mb(kb) {
        return (kb / 1024).toFixed(0) + "M";
    }
    function time(sec) {
        var h = Math.floor(sec / 3600);
        var m = Math.floor((sec % 3600) / 60);
        return h > 0 ? h + "h " + m + "m" : m + "m";
    }

    Behavior on width {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }
    Behavior on height {
        NumberAnimation {
            duration: 250
            easing.type: Easing.OutCubic
        }
    }

    HoverHandler {
        id: hover
    }

    Rectangle {
        anchors.fill: parent
        color: Appearance.colors.m3surface
        radius: 20
        opacity: hover.hovered ? 1 : 0.85
        layer.enabled: true

        Behavior on opacity {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 12
        spacing: 8

        // Compact view
        RowLayout {
            visible: !root.expanded
            spacing: 10

            MaterialIcon {
                icon: 'speed'
                font.pixelSize: 16
                color: root.smoothFps < 30 ? Appearance.colors.m3error : root.smoothFps < 50 ? "#FFA726" : "#66BB6A"
            }

            RowLayout {
                spacing: 1

                StyledText {
                    text: Math.floor(root.smoothFps)
                    color: root.smoothFps < 30 ? Appearance.colors.m3error : root.smoothFps < 50 ? "#FFA726" : "#66BB6A"
                    font.pixelSize: 24
                    font.family: "JetBrainsMono Nerd Font"
                    font.weight: Font.Bold
                }

                Column {
                    spacing: -2
                    anchors.top: parent.top
                    anchors.topMargin: 4

                    StyledText {
                        text: (root.smoothFps % 1).toFixed(1).substring(1)
                        color: root.smoothFps < 30 ? Appearance.colors.m3error : root.smoothFps < 50 ? "#FFA726" : "#66BB6A"
                        font.pixelSize: 12
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: Font.Bold
                    }

                    StyledText {
                        text: "fps"
                        color: Appearance.colors.m3on_surface
                        opacity: 0.4
                        font.pixelSize: 9
                        font.family: "JetBrainsMono Nerd Font"
                    }
                }
            }

            Rectangle {
                width: 1
                height: 20
                color: Appearance.colors.m3outline
                opacity: 0.3
            }

            Column {
                spacing: 1

                StyledText {
                    text: root.drops + " drops"
                    color: root.drops > 0 ? Appearance.colors.m3error : Appearance.colors.m3on_surface
                    opacity: 0.7
                    font.pixelSize: 9
                    font.family: "JetBrainsMono Nerd Font"
                }

                StyledText {
                    text: root.time(System.uptime)
                    color: Appearance.colors.m3on_surface
                    opacity: 0.5
                    font.pixelSize: 9
                    font.family: "JetBrainsMono Nerd Font"
                }
            }
        }

        // Expanded view
        Column {
            visible: root.expanded
            spacing: 12
            opacity: root.expanded ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 200
                }
            }

            // FPS section
            Column {
                spacing: 6

                Row {
                    spacing: 8

                    MaterialIcon {
                        icon: 'speed'
                        font.pixelSize: 16
                        color: root.smoothFps < 30 ? Appearance.colors.m3error : root.smoothFps < 50 ? "#FFA726" : "#66BB6A"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    RowLayout {
                        spacing: 1
                        anchors.verticalCenter: parent.verticalCenter

                        StyledText {
                            text: Math.floor(root.smoothFps)
                            color: root.smoothFps < 30 ? Appearance.colors.m3error : root.smoothFps < 50 ? "#FFA726" : "#66BB6A"
                            font.pixelSize: 20
                            font.family: "JetBrainsMono Nerd Font"
                            font.weight: Font.Bold
                        }

                        Column {
                            spacing: -2
                            anchors.top: parent.top
                            anchors.topMargin: 2

                            StyledText {
                                text: (root.smoothFps % 1).toFixed(1).substring(1)
                                color: root.smoothFps < 30 ? Appearance.colors.m3error : root.smoothFps < 50 ? "#FFA726" : "#66BB6A"
                                font.pixelSize: 11
                                font.family: "JetBrainsMono Nerd Font"
                                font.weight: Font.Bold
                            }

                            StyledText {
                                text: "fps"
                                color: Appearance.colors.m3on_surface
                                opacity: 0.5
                                font.pixelSize: 8
                                font.family: "JetBrainsMono Nerd Font"
                            }
                        }
                    }

                    StyledText {
                        text: root.drops > 0 ? "(" + root.drops + " drops)" : ""
                        color: Appearance.colors.m3error
                        opacity: 0.8
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Canvas {
                    id: fpsChart
                    width: 200
                    height: 40

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        ctx.fillStyle = Qt.rgba(0, 0, 0, 0.1);
                        ctx.fillRect(0, 0, width, height);

                        if (root.fpsGraph.length < 2)
                            return;

                        var color = root.smoothFps < 30 ? Appearance.colors.m3error : root.smoothFps < 50 ? "#FFA726" : "#66BB6A";
                        var max = 80;
                        var step = width / 60;

                        var grad = ctx.createLinearGradient(0, 0, 0, height);
                        grad.addColorStop(0, color);
                        grad.addColorStop(1, "transparent");

                        ctx.fillStyle = grad;
                        ctx.globalAlpha = 0.25;
                        ctx.beginPath();
                        ctx.moveTo(0, height);

                        for (var i = 0; i < root.fpsGraph.length; i++) {
                            var x = i * step;
                            var y = height - (root.fpsGraph[i] / max * height);
                            ctx.lineTo(x, Math.max(0, Math.min(height, y)));
                        }

                        ctx.lineTo(width, height);
                        ctx.closePath();
                        ctx.fill();

                        ctx.globalAlpha = 1;
                        ctx.strokeStyle = color;
                        ctx.lineWidth = 2;
                        ctx.beginPath();

                        for (var j = 0; j < root.fpsGraph.length; j++) {
                            var x2 = j * step;
                            var y2 = height - (root.fpsGraph[j] / max * height);
                            j === 0 ? ctx.moveTo(x2, y2) : ctx.lineTo(x2, y2);
                        }

                        ctx.stroke();
                    }
                }
            }

            // Memory section
            Column {
                spacing: 6

                Row {
                    spacing: 8

                    MaterialIcon {
                        icon: 'memory'
                        font.pixelSize: 16
                        color: "#64B5F6"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.mb(root.memRss)
                        color: Appearance.colors.m3on_surface
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Canvas {
                    id: memChart
                    width: 200
                    height: 40

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        ctx.fillStyle = Qt.rgba(0, 0, 0, 0.1);
                        ctx.fillRect(0, 0, width, height);

                        if (root.memGraph.length < 2)
                            return;

                        var max = Math.max(...root.memGraph);
                        if (max === 0)
                            return;

                        var step = width / 60;

                        var grad = ctx.createLinearGradient(0, 0, 0, height);
                        grad.addColorStop(0, "#64B5F6");
                        grad.addColorStop(1, "transparent");

                        ctx.fillStyle = grad;
                        ctx.globalAlpha = 0.3;
                        ctx.beginPath();
                        ctx.moveTo(0, height);

                        for (var i = 0; i < root.memGraph.length; i++) {
                            var x = i * step;
                            var y = height - (root.memGraph[i] / max * height);
                            ctx.lineTo(x, y);
                        }

                        ctx.lineTo(width, height);
                        ctx.closePath();
                        ctx.fill();

                        ctx.globalAlpha = 1;
                        ctx.strokeStyle = "#64B5F6";
                        ctx.lineWidth = 2;
                        ctx.beginPath();

                        for (var j = 0; j < root.memGraph.length; j++) {
                            var x2 = j * step;
                            var y2 = height - (root.memGraph[j] / max * height);
                            j === 0 ? ctx.moveTo(x2, y2) : ctx.lineTo(x2, y2);
                        }

                        ctx.stroke();
                    }
                }
            }

            // CPU section
            Column {
                spacing: 6

                Row {
                    spacing: 8

                    MaterialIcon {
                        icon: 'developer_board'
                        font.pixelSize: 16
                        color: "#FF7043"
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.cpuPercent.toFixed(1) + "%"
                        color: Appearance.colors.m3on_surface
                        font.pixelSize: 14
                        font.family: "JetBrainsMono Nerd Font"
                        font.weight: Font.Bold
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.threads + " threads"
                        color: Appearance.colors.m3on_surface
                        opacity: 0.5
                        font.pixelSize: 10
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                Canvas {
                    id: cpuChart
                    width: 200
                    height: 40

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();

                        ctx.fillStyle = Qt.rgba(0, 0, 0, 0.1);
                        ctx.fillRect(0, 0, width, height);

                        if (root.cpuGraph.length < 2)
                            return;

                        var max = 100;
                        var step = width / 60;

                        var grad = ctx.createLinearGradient(0, 0, 0, height);
                        grad.addColorStop(0, "#FF7043");
                        grad.addColorStop(1, "transparent");

                        ctx.fillStyle = grad;
                        ctx.globalAlpha = 0.3;
                        ctx.beginPath();
                        ctx.moveTo(0, height);

                        for (var i = 0; i < root.cpuGraph.length; i++) {
                            var x = i * step;
                            var y = height - (root.cpuGraph[i] / max * height);
                            ctx.lineTo(x, Math.max(0, Math.min(height, y)));
                        }

                        ctx.lineTo(width, height);
                        ctx.closePath();
                        ctx.fill();

                        ctx.globalAlpha = 1;
                        ctx.strokeStyle = "#FF7043";
                        ctx.lineWidth = 2;
                        ctx.beginPath();

                        for (var j = 0; j < root.cpuGraph.length; j++) {
                            var x2 = j * step;
                            var y2 = height - (root.cpuGraph[j] / max * height);
                            j === 0 ? ctx.moveTo(x2, y2) : ctx.lineTo(x2, y2);
                        }

                        ctx.stroke();
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            Layout.topMargin: 4
            color: Appearance.colors.m3outline
            opacity: 0.2
            visible: root.expanded || hover.hovered
        }

        // Controls
        RowLayout {
            spacing: 6
            visible: root.expanded || hover.hovered
            opacity: root.expanded || hover.hovered ? 1 : 0
            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                }
            }

            MouseArea {
                Layout.preferredWidth: toggle.width
                Layout.preferredHeight: toggle.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.expanded = !root.expanded

                property bool hover: containsMouse

                Row {
                    id: toggle
                    spacing: 3

                    MaterialIcon {
                        icon: root.expanded ? 'unfold_less' : 'unfold_more'
                        font.pixelSize: 12
                        color: parent.parent.hover ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                        opacity: parent.parent.hover ? 1 : 0.5
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: root.expanded ? "hide" : "expand"
                        color: parent.parent.hover ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                        opacity: parent.parent.hover ? 1 : 0.5
                        font.pixelSize: 9
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            Item {
                Layout.fillWidth: true
            }

            MouseArea {
                Layout.preferredWidth: reset.width
                Layout.preferredHeight: reset.height
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    root.drops = 0;
                    root.fpsGraph = [];
                    root.memGraph = [];
                    root.cpuGraph = [];
                }

                property bool hover: containsMouse

                Row {
                    id: reset
                    spacing: 3

                    MaterialIcon {
                        icon: 'refresh'
                        font.pixelSize: 12
                        color: parent.parent.hover ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                        opacity: parent.parent.hover ? 1 : 0.5
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    StyledText {
                        text: "reset"
                        color: parent.parent.hover ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                        opacity: parent.parent.hover ? 1 : 0.5
                        font.pixelSize: 9
                        font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }

    Process {
        id: procStats
        command: ["ps", "-p", Quickshell.processId.toString(), "-o", "%cpu,rss,nlwp", "--no-headers"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(/\s+/);
                if (parts.length >= 3) {
                    root.cpuPercent = parseFloat(parts[0]);
                    root.memRss = parseInt(parts[1]);
                    root.threads = parseInt(parts[2]);

                    root.cpuGraph.push(root.cpuPercent);
                    if (root.cpuGraph.length > 60)
                        root.cpuGraph.shift();

                    root.memGraph.push(root.memRss);
                    if (root.memGraph.length > 60)
                        root.memGraph.shift();

                    if (root.expanded) {
                        memChart.requestPaint();
                        cpuChart.requestPaint();
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: procStats.running = true
    }

    FrameAnimation {
        running: true

        onTriggered: {
            var now = Date.now();
            root.frameLog.push(now);

            while (root.frameLog.length > 0 && now - root.frameLog[0] > 1000) {
                root.frameLog.shift();
            }

            root.fps = root.frameLog.length;
            root.smoothFps = root.lerp(root.smoothFps, root.fps, 0.2);

            if (root.lastFps > 0 && root.lastFps - root.smoothFps > 10) {
                root.drops++;
            }

            root.lastFps = root.smoothFps;

            root.fpsGraph.push(root.smoothFps);
            if (root.fpsGraph.length > 60)
                root.fpsGraph.shift();

            fpsChart.requestPaint();
        }
    }
}
