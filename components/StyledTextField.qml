import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs.modules

TextField {
    id: control

    // Public properties
    property string icon: ""
    property color iconColor: Colors.foreground
    property string placeholder: "Type here..."
    property real iconSize: icon === "" ? 0 : 25
    property real radius: 20
    property color backgroundColor: Colors.opacify(Colors.background, 0.7)
    property color borderActive: Colors.opacify(Colors.foreground, 0.7)
    property color borderInactive: Colors.opacify(Colors.foreground, 0.25)

    width: parent ? parent.width - 40 : 300
    placeholderText: placeholder
    font.pixelSize: 16
    padding: 20
    leftPadding: icon !== "" ? iconSize + 35 : 0
    color: Colors.foreground
    placeholderTextColor: Colors.opacify(Colors.foreground, 0.4)
    cursorVisible: true

    // Smooth blinking cursor
    cursorDelegate: Rectangle {
        width: 2
        radius: 1
        color: Colors.foreground
        SequentialAnimation on opacity {
            loops: Animation.Infinite
            NumberAnimation { from: 1; to: 0; duration: 2000; easing.type: Easing.OutCubic }
            NumberAnimation { from: 0; to: 1; duration: 2000; easing.type: Easing.OutCubic }
        }
    }

    // Background with animated border color
    background: Rectangle {
        id: bg
        radius: control.radius
        color: control.backgroundColor
        border.color: control.activeFocus ? control.borderActive : control.borderInactive
        border.width: 1

        Behavior on border.color { ColorAnimation { duration: 180 } }
        Behavior on color { ColorAnimation { duration: 180 } }
    }

    MaterialSymbol {
        icon: control.icon
        anchors.left: parent.left
        anchors.leftMargin: control.icon !== "" ? 20 : 0
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: control.iconSize
        color: control.iconColor
        visible: control.icon !== ""
    }
}
