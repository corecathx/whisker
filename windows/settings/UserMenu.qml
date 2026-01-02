import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.preferences
import qs.components
import qs.modules
import qs.services
BaseMenu {
    title: "User"
    description: "Manage current active user"

    InfoCard {
        icon: "info"
        backgroundColor: Appearance.colors.m3primary
        contentColor: Appearance.colors.m3on_primary
        title: "Heads up!"
        description: "This menu is still being developed, so things might change overtime!"
    }

    BaseCard {
        Item {
            id: userIcon
            Layout.alignment: Qt.AlignHCenter
            width: icon.width
            height: icon.height
            ProfileIcon {
                id: icon
                implicitWidth: 150
            }
            StyledButton {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                }
                icon: "edit"
                // onClicked
            }
            Process {
                id: setPfpProc
                // command
            }
        }
    }
}
