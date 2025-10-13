import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.modules
import qs.components
import qs.services

Item {
    id: root
    property bool showLabel: true
    property bool verticalMode: false

    Layout.preferredWidth: verticalMode ? container.implicitWidth : showLabel ? container.implicitWidth : 0
    Layout.preferredHeight: verticalMode ? (showLabel ? container.implicitHeight : 0) : container.implicitHeight
    width: container.implicitWidth
    height: container.implicitHeight
    opacity: showLabel ? 1 : 0

    Column {
        spacing: verticalMode ? -2 : -5
        id: container
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            spacing: -2
            anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined

            StyledText {
                text: verticalMode ? Qt.formatDateTime(Time.date, "HH") : Qt.formatDateTime(Time.date, "HH:mm")
                color: Appearance.colors.m3on_surface
                font.pixelSize: 18
                font.family: "Outfit ExtraBold"
                lineHeight: 0.1
                anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined
            }

            StyledText {
                visible: verticalMode
                text: Qt.formatDateTime(Time.date, "mm")
                color: Appearance.colors.m3on_surface
                font.pixelSize: 18
                font.family: "Outfit ExtraBold"
                font.bold: true
                lineHeight: 0.1
                anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined
            }
        }

        StyledText {
            text: verticalMode ? Qt.formatDateTime(Time.date, "dd/MM") : Qt.formatDateTime(Time.date, "ddd, dd/MM")
            color: Appearance.colors.m3on_surface
            font.pixelSize: 12
            lineHeight: 0.1
            anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined

        }
    }

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
    Behavior on Layout.preferredHeight {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
    Behavior on opacity {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
    HoverHandler {
        id: hover

    }
    StyledPopout {
        hoverTarget:hover
        interactable: true
        Component {
            Calendar {}
        }
    }
}
