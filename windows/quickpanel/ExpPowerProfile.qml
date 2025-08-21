import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules
import qs.components

RowLayout {
    id: root
    spacing: 12
    anchors.margins: 20
    Layout.leftMargin: 20
    Layout.rightMargin: 20

    property string current_mode: "Balanced"

    StyledButton {
        id: btn_saver
        text: "Power Saver"
        icon: "eco"
        checkable: true
        Layout.fillWidth: true
        onToggled: if (checked) {
            btn_balanced.checked = false
            btn_perf.checked = false
            root.current_mode = "Power Saver"
            console.log("Current mode:", root.current_mode)
        }
    }

    StyledButton {
        id: btn_balanced
        text: "Balanced"
        icon: "tune"
        checkable: true
        checked: true
        Layout.fillWidth: true
        onToggled: if (checked) {
            btn_saver.checked = false
            btn_perf.checked = false
            root.current_mode = "Balanced"
            console.log("Current mode:", root.current_mode)
        }
    }

    StyledButton {
        id: btn_perf
        text: "Performance"
        icon: "flash_on"
        checkable: true
        Layout.fillWidth: true
        onToggled: if (checked) {
            btn_saver.checked = false
            btn_balanced.checked = false
            root.current_mode = "Performance"
            console.log("Current mode:", root.current_mode)
        }
    }
}
