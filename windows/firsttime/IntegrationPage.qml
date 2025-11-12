import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell
import Quickshell.Widgets
import qs.modules
import qs.components
import qs.preferences
import qs.windows.settings
SetupMenu {
    id:root
    property bool execsIntegration: false
    property bool keybindsIntegration: false
    property bool rulesIntegration: false
    title: "Integration"
    description: "Choose which types of integration you'd like to enable."
    canContinue: !applyProcess.running
    InfoCard {
        title: "Hey there!"
        description: "This step is optional, you can skip it if you want."
    }
    IntegrationField {
        title: "Keybinds"
        description: "When enabled, Whisker's keybinds (like opening the launcher or settings) will work."
        prefField: "keybinds"
    }
    IntegrationField {
        title: "Auto startup"
        description: "Enable this to automatically start Whisker when you log in to Hyprland."
        prefField: "execs"
    }
    IntegrationField {
        title: "Hyprland Rules"
        description: "Uses Hyprland rules for proper Whisker behavior."
        prefField: "rules"
    }
    StyledButton {
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: 200
        text: "Apply"
        enabled: root.execsIntegration || root.keybindsIntegration || root.rulesIntegration
        opacity: root.execsIntegration || root.keybindsIntegration || root.rulesIntegration ? 1 : 0.2
        secondary: !(root.execsIntegration || root.keybindsIntegration || root.rulesIntegration)
        onClicked: {
            const types = []
            if (root.execsIntegration) types.push("execs")
            if (root.keybindsIntegration) types.push("keybinds")
            if (root.rulesIntegration) types.push("rules")

            const typeThings = types.join(",")
            console.log(typeThings);
            applyProcess.command = ["whisker", "integration", "hyprland", "apply", typeThings]
            applyProcess.running = true
        }
    }
    Rectangle {
        visible: applyProcess.running
        anchors.fill: parent
        color: Colors.opacify(Appearance.colors.m3surface, 0.2)
        LoadingIcon { anchors.centerIn: parent}
    }
    Process {
        id: applyProcess
        stdout: StdioCollector {
            onStreamFinished: {
            }
        }
    }
    component IntegrationField: RowLayout {
        id: main
        property string title: "Title"
        property string description: "Description"
        property string prefField: ''
        ColumnLayout {
            StyledText {
                text: main.title
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
            }
            StyledText {
                text: main.description
                font.pixelSize: 12
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }
        Item {
            Layout.fillWidth: true
        }
        StyledSwitch {
            checked: root[prefField+"Integration"]
            onToggled: {
                root[prefField+"Integration"] = checked
            }
        }
    }
}
