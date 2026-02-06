import qs.components
import qs.services
import qs.modules
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules.corners

FloatingWindow {
    id: win

    property string currentPath: Quickshell.env("HOME")
    property string filterLabel: "All files"
    property list<string> filters: ["*"]
    property string windowTitle: "Select a file"
    property var selectedFile: null
    property bool showHidden: false
    property bool gridMode: false
    property var folderModel: []
    property int gridSize: 140
    readonly property int gridMin: 100
    readonly property int gridMax: 240
    readonly property bool selectionValid: selectedFile && !selectedFile.isDir

    signal accepted(path: string)
    signal rejected()

    implicitWidth: 1000
    implicitHeight: 600
    color: Appearance.colors.m3background
    title: windowTitle
    visible: false

    function resetState() {
        selectedFile = null;
        showHidden = false;
        refreshDirectory();
    }

    function navigateToPath(path) {
        currentPath = path;
        selectedFile = null;
        refreshDirectory();
    }

    function refreshDirectory() {
        lsProcess.running = true;
        itemCountProcess.running = true;
    }

    Component.onCompleted: refreshDirectory()

    Behavior on color {
        ColorAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    Process {
        id: lsProcess
        command: ["ls", "-lAh", "--time-style=+%b %d %Y", "--group-directories-first", currentPath]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = text.trim().split('\n');
                const files = [];

                for (let i = 1; i < lines.length; i++) {
                    const line = lines[i];
                    if (!line) continue;

                    const parts = line.split(/\s+/);
                    if (parts.length < 9) continue;

                    const perms = parts[0];
                    const isDir = perms.startsWith('d');
                    const name = parts.slice(8).join(' ');

                    if (name === '.' || name === '..') continue;

                    const isHidden = name.startsWith('.');
                    if (isHidden && !showHidden) continue;

                    let ext = "";
                    if (!isDir) {
                        const lastDot = name.lastIndexOf('.');
                        if (lastDot > 0) ext = name.substring(lastDot + 1).toLowerCase();
                    }

                    if (!isDir && !filters.includes("*") && !filters.includes(ext)) continue;

                    files.push({
                        name: name,
                        isDir: isDir,
                        isHidden: isHidden,
                        ext: ext,
                        perms: perms,
                        rawSize: parts[4],
                        modified: parts.slice(5, 8).join(' '),
                        itemCount: 0
                    });
                }

                folderModel = files;
            }
        }
    }

    Process {
        id: itemCountProcess
        command: ["sh", "-c", "for d in " + currentPath + "/*/; do [ -d \"$d\" ] && echo \"$(basename \"$d\"):$(ls -A \"$d\" 2>/dev/null | wc -l)\"; done"]
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const counts = {};
                const lines = text.trim().split('\n');

                for (const line of lines) {
                    if (!line) continue;
                    const [dirName, count] = line.split(':');
                    if (dirName && count) counts[dirName] = parseInt(count);
                }

                const updatedModel = [];
                for (let i = 0; i < folderModel.length; i++) {
                    const oldItem = folderModel[i];
                    const item = {
                        name: oldItem.name,
                        isDir: oldItem.isDir,
                        isHidden: oldItem.isHidden,
                        ext: oldItem.ext,
                        perms: oldItem.perms,
                        rawSize: oldItem.rawSize,
                        modified: oldItem.modified,
                        itemCount: oldItem.isDir && counts[oldItem.name] !== undefined ? counts[oldItem.name] : 0
                    };
                    updatedModel.push(item);
                }
                folderModel = updatedModel;
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Item {
            Layout.fillWidth: true
            Layout.preferredHeight: 46

            StyledText {
                text: windowTitle
                font.family: "Outfit SemiBold"
                font.pixelSize: 20
                color: Appearance.colors.m3on_surface
                anchors.centerIn: parent
            }

            StyledButton {
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                icon: 'close'
                base_fg: Appearance.colors.m3on_surface
                base_bg: Appearance.colors.m3surface
                onClicked: rejected()
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 32

            Rectangle {
                Layout.preferredWidth: 250
                Layout.fillHeight: true
                color: Appearance.colors.m3surface
                radius: Appearance.rounding.large

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 32
                    anchors.topMargin: 12
                    spacing: 0

                    Repeater {
                        model: [
                            { icon: "home", label: "Home", path: Quickshell.env("HOME") },
                            { icon: "folder", label: "Documents", path: Quickshell.env("HOME") + "/Documents" },
                            { icon: "download", label: "Downloads", path: Quickshell.env("HOME") + "/Downloads" },
                            { icon: "photo", label: "Pictures", path: Quickshell.env("HOME") + "/Pictures" },
                            { icon: "music_note", label: "Music", path: Quickshell.env("HOME") + "/Music" },
                            { icon: "movie", label: "Videos", path: Quickshell.env("HOME") + "/Videos" }
                        ]

                        Rectangle {
                            required property var modelData
                            Layout.fillWidth: true
                            Layout.preferredHeight: 40
                            color: {
                                if (currentPath === modelData.path) return Appearance.colors.m3on_primary;
                                if (sidebarMouse.containsMouse) return Appearance.colors.m3surface_container_high;
                                return Appearance.colors.m3surface;
                            }
                            radius: Appearance.rounding.extraLarge

                            Behavior on color {
                                ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
                            }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10

                                MaterialIcon {
                                    icon: modelData.icon
                                    color: currentPath === modelData.path
                                        ? Appearance.colors.m3on_primary_container
                                        : Appearance.colors.m3on_surface
                                    font.pixelSize: 20
                                }

                                StyledText {
                                    text: modelData.label
                                    color: currentPath === modelData.path
                                        ? Appearance.colors.m3on_primary_container
                                        : Appearance.colors.m3on_surface
                                    font.pixelSize: 14
                                }

                                Item { Layout.fillWidth: true }
                            }

                            MouseArea {
                                id: sidebarMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: navigateToPath(modelData.path)
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.rightMargin: 10
                Layout.bottomMargin: 10
                Layout.fillHeight: true
                spacing: 12

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    radius: Appearance.rounding.large
                    color: Appearance.colors.m3surface_container

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        StyledButton {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            icon: "chevron_left"
                            secondary: true
                            enabled: currentPath !== "/"
                            onClicked: {
                                const lastSlash = currentPath.lastIndexOf('/');
                                navigateToPath(currentPath.substring(0, lastSlash) || "/");
                            }
                        }

                        StyledButton {
                            Layout.preferredWidth: 36
                            Layout.preferredHeight: 36
                            icon: "refresh"
                            secondary: true
                            onClicked: refreshDirectory()
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            color: Appearance.colors.m3surface_container_high
                            radius: Appearance.rounding.medium

                            ScrollView {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                clip: true
                                contentWidth: breadcrumbFlow.width
                                ScrollBar.vertical.policy: ScrollBar.AlwaysOff

                                Flow {
                                    id: breadcrumbFlow
                                    height: parent.height
                                    spacing: 0

                                    Repeater {
                                        id: crumbRepeater
                                        model: {
                                            const parts = currentPath.split('/').filter(p => p.length > 0);
                                            const crumbs = [{ name: "/", path: "/" }];
                                            let acc = "";
                                            for (const part of parts) {
                                                acc += "/" + part;
                                                crumbs.push({ name: part, path: acc });
                                            }
                                            return crumbs;
                                        }

                                        delegate: BreadcrumbEntry {
                                            required property var modelData
                                            required property int index
                                            isLastEntry: index == crumbRepeater.model.length - 1
                                        }
                                    }
                                }
                            }
                        }

                        StyledButton {
                            icon: showHidden ? "visibility_off" : "visibility"
                            secondary: true
                            tooltipText: showHidden ? "Hide hidden files" : "Show hidden files"
                            onClicked: {
                                showHidden = !showHidden;
                                refreshDirectory();
                            }
                        }

                        StyledButton {
                            icon: gridMode ? "view_list" : "grid_view"
                            secondary: true
                            tooltipText: gridMode ? "List view" : "Grid view"
                            onClicked: gridMode = !gridMode
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: Appearance.colors.m3surface_container
                    radius: Appearance.rounding.large

                    Item {
                        anchors.fill: parent
                        SingleCorner {
                            cornerType: 'inverted'
                            color: Appearance.colors.m3background
                            corner: 1
                            cornerHeight: Appearance.rounding.large
                            anchors { top: parent.top; left: parent.left }
                        }
                        SingleCorner {
                            cornerType: 'inverted'
                            color: Appearance.colors.m3background
                            corner: 0
                            cornerHeight: Appearance.rounding.large
                            anchors { top: parent.top; right: parent.right }
                        }
                        SingleCorner {
                            cornerType: 'inverted'
                            color: Appearance.colors.m3background
                            corner: 3
                            cornerHeight: Appearance.rounding.large
                            anchors { bottom: parent.bottom; right: parent.right }
                        }
                        SingleCorner {
                            cornerType: 'inverted'
                            color: Appearance.colors.m3background
                            corner: 2
                            cornerHeight: Appearance.rounding.large
                            anchors { bottom: parent.bottom; left: parent.left }
                        }
                    }

                    Rectangle {
                        visible: !gridMode
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 20
                            bottomMargin: 0
                        }
                        height: 32
                        color: Appearance.colors.m3surface_container_high
                        radius: Appearance.rounding.small

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            anchors.rightMargin: 12
                            spacing: 12

                            Item { Layout.preferredWidth: 22 }
                            StyledText {
                                Layout.fillWidth: true
                                text: "Name"
                                color: Appearance.colors.m3on_surface_variant
                                font.pixelSize: 12
                                font.family: "Outfit Medium"
                            }
                            StyledText {
                                Layout.preferredWidth: 80
                                text: "Type"
                                color: Appearance.colors.m3on_surface_variant
                                font.pixelSize: 12
                                font.family: "Outfit Medium"
                            }
                            StyledText {
                                Layout.preferredWidth: 100
                                text: "Modified"
                                color: Appearance.colors.m3on_surface_variant
                                font.pixelSize: 12
                                font.family: "Outfit Medium"
                            }
                            StyledText {
                                Layout.preferredWidth: 80
                                text: "Size"
                                color: Appearance.colors.m3on_surface_variant
                                font.pixelSize: 12
                                font.family: "Outfit Medium"
                                horizontalAlignment: Text.AlignRight
                            }
                        }
                    }

                    ScrollView {
                        anchors {
                            fill: parent
                            margins: 20
                            topMargin: gridMode ? 20 : 58
                        }
                        clip: true

                        Loader {
                            anchors.fill: parent
                            sourceComponent: gridMode ? gridViewComponent : listViewComponent
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    color: Appearance.colors.m3surface
                    radius: Appearance.rounding.large

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12

                        MaterialIcon {
                            icon: "filter_alt"
                            color: Appearance.colors.m3on_surface_variant
                            font.pixelSize: 18
                        }

                        StyledText {
                            text: filterLabel
                            color: Appearance.colors.m3on_surface_variant
                            font.pixelSize: 13
                        }

                        Item { Layout.fillWidth: true }

                        StyledButton {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 90
                            text: "Cancel"
                            secondary: true
                            onClicked: rejected()
                        }

                        StyledButton {
                            Layout.preferredHeight: 36
                            Layout.preferredWidth: 90
                            text: "Select"
                            enabled: selectionValid
                            onClicked: {
                                if (selectionValid) accepted(currentPath + "/" + selectedFile.name);
                            }
                        }
                    }
                }
            }
        }
    }

    component BreadcrumbEntry: RowLayout {
        property bool isLastEntry: false
        spacing: 2
        height: parent.height

        Rectangle {
            height: 28
            width: crumbText.width + 16
            anchors.verticalCenter: parent.verticalCenter
            color: crumbMouse.containsMouse
                ? Appearance.colors.m3surface_container_highest
                : Appearance.colors.m3surface_container_high
            radius: Appearance.rounding.small

            Behavior on color {
                ColorAnimation {
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }

            StyledText {
                id: crumbText
                anchors.centerIn: parent
                text: modelData.name
                color: Appearance.colors.m3on_surface
                font.pixelSize: 13
            }

            MouseArea {
                id: crumbMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: navigateToPath(modelData.path)
            }
        }

        MaterialIcon {
            icon: "chevron_right"
            color: Appearance.colors.m3on_surface_variant
            font.pixelSize: 16
            anchors.verticalCenter: parent.verticalCenter
            visible: !isLastEntry
        }
    }

    component FileEntry: Rectangle {
        width: folderView.width
        height: 44
        opacity: modelData.isHidden && showHidden ? 0.6 : 1.0
        color: {
            if (selectedFile === modelData) return Appearance.colors.m3primary_container;
            if (fileMouse.containsMouse) return Appearance.colors.m3surface_container_highest;
            return Appearance.colors.m3surface_container;
        }
        radius: Appearance.rounding.medium

        Behavior on color {
            ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            MaterialIcon {
                icon: modelData.isDir ? "folder" : "description"
                color: {
                    if (selectedFile === modelData) return Appearance.colors.m3on_primary_container;
                    return modelData.isDir ? Appearance.colors.m3tertiary : Appearance.colors.m3on_surface_variant;
                }
                font.pixelSize: 22
            }

            StyledText {
                Layout.fillWidth: true
                text: modelData.name
                color: selectedFile === modelData ? Appearance.colors.m3on_primary_container : Appearance.colors.m3on_surface
                font.pixelSize: 14
                elide: Text.ElideRight
            }

            StyledText {
                Layout.preferredWidth: 80
                text: modelData.isDir ? "Folder" : (modelData.ext ? modelData.ext.toUpperCase() : "File")
                color: selectedFile === modelData ? Appearance.colors.m3on_primary_container : Appearance.colors.m3on_surface_variant
                font.pixelSize: 11
                font.family: "Outfit Medium"
            }

            StyledText {
                Layout.preferredWidth: 100
                text: modelData.modified
                color: selectedFile === modelData ? Appearance.colors.m3on_primary_container : Appearance.colors.m3on_surface_variant
                font.pixelSize: 12
            }

            StyledText {
                Layout.preferredWidth: 80
                text: {
                    if (modelData.isDir) {
                        const count = modelData.itemCount;
                        return count === 0 ? "Empty" : count + (count === 1 ? " item" : " items");
                    }
                    return modelData.rawSize;
                }
                color: selectedFile === modelData ? Appearance.colors.m3on_primary_container : Appearance.colors.m3on_surface_variant
                font.pixelSize: 12
                horizontalAlignment: Text.AlignRight
            }
        }

        MouseArea {
            id: fileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: selectedFile = modelData
            onDoubleClicked: {
                if (modelData.isDir) {
                    navigateToPath(currentPath + "/" + modelData.name);
                } else {
                    accepted(currentPath + "/" + modelData.name);
                }
            }
        }
    }

    component GridEntry: Rectangle {
        width: gridSize
        height: gridSize + 50
        radius: Appearance.rounding.large
        opacity: modelData.isHidden && showHidden ? 0.6 : 1.0
        color: {
            if (selectedFile === modelData) return Appearance.colors.m3primary_container;
            if (tileMouse.containsMouse) return Appearance.colors.m3surface_container_highest;
            return "transparent";
        }

        Behavior on color {
            ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: gridSize - 50
                radius: Appearance.rounding.medium
                color: modelData.isDir ? Appearance.colors.m3tertiary_container : Appearance.colors.m3surface_container_high
                clip: true

                property bool isImageFile: !modelData.isDir && ["png","jpg","jpeg","webp","gif","bmp","svg"].includes(modelData.ext)

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: modelData.isDir ? 0 : 4
                    radius: Appearance.rounding.medium
                    clip: true
                    color: "transparent"
                    visible: parent.isImageFile

                    Image {
                        anchors.fill: parent
                        cache: true
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        source: parent.visible ? "file://" + currentPath + "/" + modelData.name : ""
                        smooth: true
                    }
                }

                MaterialIcon {
                    anchors.centerIn: parent
                    icon: {
                        if (modelData.isDir) return "folder";
                        const ext = modelData.ext;
                        if (["mp4","avi","mkv","mov","webm"].includes(ext)) return "movie";
                        if (["mp3","wav","flac","ogg","m4a"].includes(ext)) return "audiotrack";
                        if (["pdf"].includes(ext)) return "picture_as_pdf";
                        if (["zip","rar","7z","tar","gz"].includes(ext)) return "folder_zip";
                        if (["txt","md","log"].includes(ext)) return "description";
                        if (["doc","docx"].includes(ext)) return "article";
                        if (["xls","xlsx","csv"].includes(ext)) return "table_chart";
                        if (["ppt","pptx"].includes(ext)) return "slideshow";
                        return "draft";
                    }
                    visible: !parent.isImageFile
                    font.pixelSize: Math.max(32, gridSize / 3.5)
                    color: modelData.isDir ? Appearance.colors.m3on_tertiary_container : Appearance.colors.m3on_surface_variant
                }

                Rectangle {
                    visible: modelData.isDir
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    anchors.margins: 8
                    width: countText.width + 12
                    height: 22
                    radius: Appearance.rounding.small
                    color: Appearance.colors.m3tertiary

                    StyledText {
                        id: countText
                        anchors.centerIn: parent
                        text: {
                            const count = modelData.itemCount;
                            if (count === 0) return "Empty";
                            return count > 99 ? "99+" : count.toString();
                        }
                        font.pixelSize: 11
                        font.family: "Outfit Medium"
                        color: Appearance.colors.m3on_tertiary
                    }
                }
            }

            StyledText {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                text: modelData.name
                font.pixelSize: 13
                elide: Text.ElideMiddle
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                maximumLineCount: 2
                color: selectedFile === modelData ? Appearance.colors.m3on_primary_container : Appearance.colors.m3on_surface
            }
        }

        MouseArea {
            id: tileMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: selectedFile = modelData
            onDoubleClicked: {
                if (modelData.isDir) {
                    navigateToPath(currentPath + "/" + modelData.name);
                } else {
                    accepted(currentPath + "/" + modelData.name);
                }
            }
        }
    }

    Component {
        id: listViewComponent
        ListView {
            id: folderView
            spacing: 2
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            model: folderModel
            delegate: FileEntry { required property var modelData }
        }
    }

    Component {
        id: gridViewComponent
        GridView {
            cellWidth: gridSize
            cellHeight: gridSize + 50
            clip: true
            model: folderModel
            boundsBehavior: Flickable.StopAtBounds
            delegate: GridEntry { required property var modelData }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: (wheel) => {
                    if (wheel.modifiers & Qt.ControlModifier) {
                        const delta = wheel.angleDelta.y;
                        const step = 15;
                        if (delta > 0) {
                            gridSize = Math.min(gridSize + step, gridMax);
                        } else if (delta < 0) {
                            gridSize = Math.max(gridSize - step, gridMin);
                        }
                        wheel.accepted = true;
                    } else {
                        wheel.accepted = false;
                    }
                }
            }
        }
    }
}
