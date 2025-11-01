import Quickshell.Services.SystemTray
import QtQuick
import Quickshell
import Quickshell.Widgets
import QtQuick.Layouts
import qs.modules
import qs.components
import qs.preferences

Item {
    id: root
    readonly property Repeater items: items
    property bool verticalMode: false
    anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined

    clip: true
    visible: width > 0 && height > 0
    implicitWidth: layout.width
    implicitHeight: layout.height

    GridLayout {
        id: layout
        rows: root.verticalMode ? 1 : 4
        columns: root.verticalMode ? 1 : 4
        rowSpacing: 10
        columnSpacing: 10

        Repeater {
            id: items
            model: SystemTray.items
            delegate: Item {
                id: trayItemRoot
                required property SystemTrayItem modelData
                implicitWidth: 20
                implicitHeight: 20

                IconImage {
                    source: {
                        let icon = trayItemRoot.modelData.icon
                        if (icon.includes("?path=")) {
                            const [name, path] = icon.split("?path=")
                            icon = `file://${path}/${name.slice(name.lastIndexOf("/") + 1)}`
                        }
                        return icon
                    }
                    asynchronous: true
                    anchors.fill: parent
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                    hoverEnabled: true
                }

                HoverHandler {
                    id: hover
                }

                QsMenuOpener {
                    id: menuOpener
                    menu: trayItemRoot.modelData.menu
                }

                StyledPopout {
                    hoverTarget: hover
                    interactable: true
                    hCenterOnItem: true
                    Component {
                        Item {
                            width: childColumn.implicitWidth
                            height: childColumn.height
                            ColumnLayout {
                                id: childColumn
                                spacing: 5
                                Repeater {
                                    model: menuOpener.children
                                    delegate: TrayMenuItem {
                                        parentColumn: childColumn
                                        Layout.preferredWidth: childColumn.width > 0 ? childColumn.width : implicitWidth
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    component TrayMenuItem: Item {
        id: itemRoot
        required property QsMenuEntry modelData
        required property ColumnLayout parentColumn

        Layout.fillWidth: true
        implicitWidth: rowLayout.implicitWidth + 10
        implicitHeight: !itemRoot.modelData.isSeparator ? rowLayout.implicitHeight + 10 : 1

        MouseArea {
            id: hover
            hoverEnabled: itemRoot.modelData.enabled
            anchors.fill: parent
            onClicked: {
                if (!itemRoot.modelData.hasChildren) {
                    itemRoot.modelData.triggered()
                }
            }
        }
        Rectangle {
            id: itemBg
            anchors.fill: parent
            opacity: itemRoot.modelData.isSeparator ? 0.5 : 1
            color: itemRoot.modelData.isSeparator
                   ? Appearance.colors.m3outline
                   : hover.containsMouse ? Appearance.colors.m3surface_container : Appearance.colors.m3surface
        }

        RowLayout {
            id: rowLayout
            visible: !itemRoot.modelData.isSeparator
            opacity: itemRoot.modelData.isSeparator ? 0.5 : 1
            spacing: 5

            anchors {
                left: itemBg.left
                leftMargin: 5
                top: itemBg.top
                topMargin: 5
            }

            IconImage {
                visible: itemRoot.modelData.icon !== ""
                source: itemRoot.modelData.icon
                width: 15
                height: 15
            }

            StyledText {
                text: itemRoot.modelData.text
                font.pixelSize: 14
                color: Appearance.colors.m3on_surface
            }

            MaterialIcon {
                visible: itemRoot.modelData.hasChildren
                icon: "chevron_right"
                font.pixelSize: 16
                color: Appearance.colors.m3on_surface
            }
        }
    }
}
