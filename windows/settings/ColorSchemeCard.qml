import QtQuick
import QtQuick.Layouts
import qs.preferences
import qs.modules
import qs.components
import Quickshell

Item {
    id: root
    property string schemeName
    width: 100
    height: 130

    property var schemeColor: Appearance.getScheme(schemeName)
    property bool hovered: mouseHover.containsMouse

    MouseArea {
        id: mouseHover
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (Preferences.colorScheme === schemeName) return
            Quickshell.execDetached({
                command: ['whisker', 'prefs', 'set', 'colorScheme', schemeName]
            })
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: 10
        color: Preferences.colorScheme === schemeName
            ? !hovered ? schemeColor.surface_container_high : schemeColor.surface_container_highest
            : !hovered ? schemeColor.surface_container : schemeColor.surface_container_high
        Behavior on color {
            ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
        }
        border.width: Preferences.colorScheme === schemeName ? 3 : 1
        border.color: schemeColor.outline

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 10
            spacing: 10
            StyledText {
                text: schemeName
                font.pixelSize: 14
                color: schemeColor.on_surface || "#000000"
            }
            ColumnLayout {
                Rectangle { width: 30; height: 8; radius: 4; color: schemeColor.on_surface || "#000000" }
                Rectangle { width: 70; height: 8; radius: 4; color: schemeColor.on_surface || "#000000" }
            }
        }

        Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: 15; height: 15; radius: 5; color: schemeColor.secondary || "#000000"; anchors.margins: 10 }
        Rectangle { anchors.right: parent.right; anchors.bottom: parent.bottom; width: 15; height: 15; radius: 5; color: schemeColor.primary || "#000000"; anchors.rightMargin: 30; anchors.bottomMargin: 10 }
    }
}
