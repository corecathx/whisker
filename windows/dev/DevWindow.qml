import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.components

Scope {
    Window {
        id: win
        width: 600
        height: 400
        visible: true
        title: "Whisker Settings"
        color: Appearance.panel_color

        property int counter: 0

        ColumnLayout {
            anchors.centerIn: parent
            StyledDropDown {
                width: 280
                label: "Choose a fruit"
                model: ["Apple", "Banana", "Orange", "Mango", "Strawberry"]

                onSelectedIndexChanged: (index) => {
                    console.log("Selected:", model[index])
                }
            }
        }
    }
}
