import QtQuick
import QtQuick.Layouts
import qs.modules

BaseCard {
    id: root

    property alias icon: iconLabel.icon

    color: Appearance.colors.m3surface_container
    radius: 20
    cardMargin: 10
    verticalPadding: 20
    property string title: "Title"
    property string description: ""
    property bool expanded: false

    default property alias content: contentLayout.data

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            spacing: 10
            anchors.left: parent.left
            anchors.right: parent.right

            MaterialIcon {
                id: iconLabel
                icon: "person"
                font.pixelSize: 32
                color: Appearance.colors.m3on_surface
            }

            ColumnLayout {
                spacing: 0
                StyledText {
                    text: root.title
                    font.pixelSize: 16
                    font.bold: true
                    color: Appearance.colors.m3on_surface
                }
                StyledText {
                    visible: description !== ""
                    text: root.description
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }

            Item { Layout.fillWidth: true }

            StyledButton {
                icon: root.expanded ? "keyboard_arrow_up" : "keyboard_arrow_down"
                base_fg: Appearance.colors.m3on_surface
                base_bg: Appearance.colors.m3surface_container_high
                onClicked: root.expanded = !root.expanded
            }
        }

        ColumnLayout {
            id: contentLayout
            anchors.left: parent.left
            anchors.right: parent.right
            opacity: root.expanded ? 1 : 0
            visible: opacity > 0.1
            Behavior on opacity { NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
        }
    }
}
