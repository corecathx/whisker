import QtQuick
import qs.modules

Item {
    id: root
    property alias icon: mIcon.icon
    property real size: 28
    width: size
    height: size
    MaterialIcon {
        id: mIcon
        anchors.centerIn: parent
        icon: "progress_activity"
        font.pixelSize: root.size
        color: Appearance.colors.m3primary
        renderType: Text.QtRendering
    }
    RotationAnimator on rotation {
        target: mIcon
        running: true
        loops: Animation.Infinite
        from: 0
        to: 360
        duration: 1000
    }
}
