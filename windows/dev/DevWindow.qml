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

        ListModel { id: myModel }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 10

            Button {
                text: "Remove last item"
                Layout.fillWidth: true
                onClicked: {
                    if (myModel.count > 0) win.removeLast()
                }
            }

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: myModel
                orientation: ListView.Vertical
                boundsBehavior: Flickable.StopAtBounds
                spacing: 5
                interactive: false  // no scrolling needed

                delegate: Rectangle {
                    id: itemRect
                    width: parent.width
                    height: 40
                    radius: 8
                    color: "lightblue"
                    opacity: 0.0  // start invisible for add animation

                    Text {
                        anchors.centerIn: parent
                        text: model.name
                        color: "black"
                    }

                    Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                    Component.onCompleted: {
                        // Animate adding: fade in and grow
                        itemRect.opacity = 1
                        itemRect.height = 40
                    }
                }
            }
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                win.counter += 1
                myModel.append({ "name": "Item " + win.counter })
            }
        }

        // Custom remove function with animation
        function removeLast() {
            if (myModel.count === 0) return
            let index = myModel.count - 1
            let item = listView.itemAtIndex(index)
            if (item) {
                // Animate shrink/fade
                item.opacity = 0
                item.height = 0
                // Remove from model after animation duration
                Qt.callLater(() => {
                    myModel.remove(index)
                })
            } else {
                myModel.remove(index)
            }
        }
    }
}
