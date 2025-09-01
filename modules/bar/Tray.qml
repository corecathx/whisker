import Quickshell.Services.SystemTray
import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts

Item {
    id: root

    readonly property Repeater items: items

    clip: true
    visible: width > 0 && height > 0

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    RowLayout {
        id: layout

        spacing: 10

        Repeater {
            id: items

            model: SystemTray.items

            MouseArea {
                id: root

                required property SystemTrayItem modelData

                acceptedButtons: Qt.LeftButton | Qt.RightButton
                implicitWidth: 20
                implicitHeight: 20

                onClicked: event => {
                    if (event.button === Qt.LeftButton)
                        modelData.activate();
                    else
                        modelData.display(null, x, y);
                }

                IconImage {
                    id: icon

                    source: {
                        let icon = root.modelData.icon;
                        if (icon.includes("?path=")) {
                            const [name, path] = icon.split("?path=");
                            icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`;
                        }
                        return icon;
                    }
                    asynchronous: true
                    anchors.fill: parent
                }
            }
        }
    }
}