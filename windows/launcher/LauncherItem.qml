import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.modules
import qs.components
import qs.preferences

Item {
    id: itemRoot
    property var itemData
    property bool selected: false
    signal clicked

    width: parent.width
    height: 60

    Rectangle {
        id: appItem
        anchors.fill: parent
        radius: 20
        color: selected || mouseArea.containsMouse ? Appearance.colors.m3surface_container_low : Appearance.colors.m3surface

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: itemRoot.clicked()
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            anchors.leftMargin: 20
            spacing: 20

            IconImage {
                id: appicon
                asynchronous: true
                source: {
                    if (itemData.icon && itemData.icon.startsWith("whisker:"))
                        return "";
                    return Quickshell.iconPath(itemData.icon || "", true);
                }
                visible: source != ""
                smooth: false
                Layout.preferredWidth: 30
                Layout.preferredHeight: 30
                Layout.alignment: Qt.AlignVCenter
            }

            MaterialIcon {
                visible: appicon.source == ""
                icon: {
                    if (itemData.icon && itemData.icon.startsWith("whisker:"))
                        return itemData.icon.replace("whisker:", "");
                    return "terminal";
                }
                font.pixelSize: 30
                color: Appearance.colors.m3on_surface
                Layout.alignment: Qt.AlignVCenter
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                StyledText {
                    text: itemData.name || ""
                    font.pixelSize: 16
                    font.bold: true
                    color: Appearance.colors.m3on_surface
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                StyledText {
                    visible: text !== ""
                    text: itemData.comment || ""
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            MaterialIcon {
                visible: itemData.submenu !== undefined
                icon: "chevron_right"
                font.pixelSize: 24
                color: Appearance.colors.m3on_surface_variant
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
