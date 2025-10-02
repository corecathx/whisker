import QtQuick
import Quickshell
import QtQuick.Controls
import qs.modules
import qs.components
Item {
    property real progress: 0
    property string icon: ""
    property color progressColor: Appearance.colors.m3primary
    property color backgroundColor: Appearance.colors.m3secondary_container
    property bool useAnim: true
    property bool allowViewingPercentage: true
    property real strokeWidth: 2
    
    Behavior on progress {
        NumberAnimation {
            duration: useAnim ? Appearance.anim_fast : 0
            easing.type: Easing.OutCubic
        }
    }
    onProgressChanged: canvas.requestPaint()
    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: -90
        
        onPaint: {
            var ctx = getContext("2d")
            var centerX = width / 2
            var centerY = height / 2
            var radius = Math.min(centerX, centerY) - strokeWidth / 2
            var startAngle = 0
            var endAngle = (Math.PI * 2) * (progress / 100)
            
            ctx.reset()
            
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, 0, Math.PI * 2)
            ctx.lineWidth = strokeWidth
            ctx.strokeStyle = backgroundColor
            ctx.stroke()
            
            ctx.beginPath()
            ctx.arc(centerX, centerY, radius, startAngle, endAngle)
            ctx.lineWidth = strokeWidth
            ctx.strokeStyle = progressColor
            ctx.stroke()
        }
    }
    MaterialIcon {
        id: iconMaterial
        anchors.centerIn: parent
        font.pixelSize: 16
        icon: parent.icon
        color: Appearance.colors.m3primary
        opacity: 1
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    
    Text {
        id: textLabel
        anchors.centerIn: parent
        text: Math.round(parent.progress) + "%"
        color: Appearance.colors.m3primary
        font.pixelSize: 10
        opacity: 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }
    
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
            if (!parent.allowViewingPercentage) return;
            iconMaterial.opacity = 0
            textLabel.opacity = 1
        }
        onExited: {
            if (!parent.allowViewingPercentage) return;
            iconMaterial.opacity = 1
            textLabel.opacity = 0
        }
    }
}