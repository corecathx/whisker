import Quickshell.Services.SystemTray
import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts

Item {
    id: root

    readonly property Repeater items: items
    property bool verticalMode: false

    clip: true
    visible: width > 0 && height > 0

    implicitWidth: loader.item ? loader.item.implicitWidth : 0
    implicitHeight: loader.item ? loader.item.implicitHeight : 0
    anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined

    Loader {
        id: loader
        anchors.fill: parent
        
        sourceComponent: verticalMode ? verticalLayout : horizontalLayout
    }

    Component {
        id: horizontalLayout
        
        RowLayout {
            id: rowLayout
            spacing: 10
            
            Repeater {
                id: items
                model: SystemTray.items

                MouseArea {
                    id: trayItemRoot
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
                            let icon = trayItemRoot.modelData.icon;
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

    Component {
        id: verticalLayout
        
        ColumnLayout {
            id: columnLayout
            spacing: 10
            
            Repeater {
                id: items
                model: SystemTray.items

                MouseArea {
                    id: trayItemRoot
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
                            let icon = trayItemRoot.modelData.icon;
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
}