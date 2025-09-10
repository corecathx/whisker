// Tooltip.qml
import QtQuick
import QtQuick.Controls 

Item {
    id: tooltipRoot
    property Item target: targetArea  // The item the tooltip follows
    property string text: ""
    property int delay: 300             // Optional delay in ms
    property color backgroundColor: "black"
    property color textColor: "white"

    Rectangle {
        id: bg
        color: backgroundColor
        radius: 4
        opacity: 0.85
        visible: false
        z: 999
        anchors.horizontalCenter: targetArea.horizontalCenter
        anchors.top: targetArea.bottom
        anchors.topMargin: 4

        Text {
            id: label
            text: tooltipRoot.text
            color: textColor
            anchors.centerIn: parent
            font.pixelSize: 12
        }

        Behavior on visible { NumberAnimation { duration: 150 } }
    }

    Timer {
        id: showTimer
        interval: delay
        onTriggered: bg.visible = true
    }

    MouseArea {
        id: targetArea
        anchors.fill: parent
        hoverEnabled: true

        onEntered: showTimer.start()
        onExited: {
            showTimer.stop()
            bg.visible = false
        }
    }
}
