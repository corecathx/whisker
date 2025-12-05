import Quickshell
import Quickshell.Services.Pipewire
import Quickshell.Io
import Quickshell.Widgets
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Window
import qs.modules
import qs.services
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
            Repeater {
                model: Pipewire.links
                delegate: StyledText {
                    text: modelData.source.description +" >> "+ modelData.target.name + (!modelData.source.isStream && !modelData.source.isSink && modelData.target.isStream ? " ?? IS AN APP!!!!!" : "")
                    font.family: ""
                }
            }
        }

        StyledText {
            anchors.bottom: parent.bottom
            text: JSON.stringify(Privacy.microphoneApps)
            width: parent.width
            wrapMode: Text.WordWrap
        }
    }
}
