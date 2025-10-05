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

            Text {
                text: verticalMode ? Qt.formatDateTime(Time.date, "HH") : Qt.formatDateTime(Time.date, "HH:mm")
                color: Appearance.colors.m3on_surface
                font.pixelSize: 18
                font.family: "Outfit ExtraBold"
                lineHeight: 0.1
                anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined
            }

            Text {
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

        Text {
            text: verticalMode ? Qt.formatDateTime(Time.date, "dd/MM") : Qt.formatDateTime(Time.date, "ddd, dd/MM")
            color: Appearance.colors.m3on_surface
            font.pixelSize: 12
            lineHeight: 0.1
            anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined

        }
    }

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo }
    }
    Behavior on Layout.preferredHeight {
        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo }
    }
    Behavior on opacity {
        NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo }
    }
    MouseArea {
        id: hover
        anchors.fill: parent
        hoverEnabled: true
        StyledPopout {
            hoverTarget:hover
            interactable: true
            Calendar {}
        }
    }
}
