import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import qs.components
import qs.modules

Rectangle {
    id: root
    color: "transparent"
    Layout.fillWidth: true
    Layout.fillHeight: true
    radius: 20
    height: 40

    property real value: 50
    property color barColor: Appearance.colors.m3primary
    property color backgroundColor: Appearance.colors.m3surface_variant
    readonly property string labelText: value.toFixed(0) + "%"
    property string icon: {
        return "adjust"
    }
    property bool dragging: false

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            root.dragging = false
            updateFromMouse(mouse.x)
        }
        onPositionChanged:  {
            root.dragging = true
            if (mouse.buttons & Qt.LeftButton)
                updateFromMouse(mouse.x)
        }
        onReleased: root.dragging = false

        function updateFromMouse(xPos) {
            root.value = Math.min(100, Math.max(0, xPos / root.width * 100))
        }
    }

    Rectangle {
        height: 10
        radius: 20
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        color: root.backgroundColor
        anchors.leftMargin: parent.height * 0.5
        anchors.rightMargin: parent.height * 0.5
    }

    Rectangle {
        id: bar
        radius: 20
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        height: 10
        width: root.height + (root.width - root.height) * value / 100
        color: root.barColor

        Behavior on width {
            enabled: !root.dragging
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }
        }

        MaterialIcon {
            icon: root.icon
            font.pixelSize: 24
            color: Appearance.colors.m3on_primary
            anchors.right: parent.width > parent.height ? parent.right : undefined
            anchors.left: parent.width > parent.height ? undefined : parent.left
            anchors.centerIn: parent.width > parent.height ? undefined : parent
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: parent.width > parent.height ? 10 : 0
        }
    }
}
