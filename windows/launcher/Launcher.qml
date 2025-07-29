import QtQuick.Layouts
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.modules

Scope {
    PanelWindow {
        margins.bottom: 10
        width: screen.height * 0.7
        height: screen.height * 0.7
        anchors {
            bottom: true
        }
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Normal
        color: 'transparent'

        Rectangle {
            anchors.fill: parent
            color: Colors.background
            radius: 20
        }

        Flickable {
            anchors.fill: parent
            anchors.margins: 20
            contentWidth: width
            contentHeight: column.implicitHeight
            clip: true

            Column {
                id: column
                width: parent.width

                Repeater {
                    model: DesktopEntries.applications

                    delegate: Item {
                        width: parent.width
                        height: 50

                        Rectangle {
                            id: appItem
                            anchors.fill: parent
                            anchors.margins: 5
                            radius: 20
                            color: hovered ? Colors.opacify(Colors.accent, 0.3) : Colors.opacify(Colors.accent, 0.2)
                            border.color: Colors.opacify(Colors.accent, 0.5)
                            border.width: 1

                            MouseArea {
                                id: mouseArea
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: modelData.execute()
                            }

                            property bool hovered: mouseArea.containsMouse

                            RowLayout {
                                anchors.fill: parent
                                anchors.margins: 10
                                spacing: 10

                                Image {
                                    source: modelData.icon
                                    sourceSize.width: 20
                                    sourceSize.height: 20 
                                }

                                Text {
                                    text: modelData.name
                                    font.pixelSize: 16
                                    color: Colors.foreground
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
