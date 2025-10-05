import qs.modules
import qs.preferences
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
LazyLoader {
    id: root
    property Item hoverTarget
    property real margin: 10
    default property list<Item> content
    property bool startAnim: false
    property bool isVisible: false
    property bool keepAlive: false
    property bool interactable: false
    property bool hasHitbox: true

    property list<StyledPopout> childPopouts: []

    property bool hoverActive: {
        let targetHovered = hoverTarget && hoverTarget.containsMouse
        let containerHovered = interactable && root.item && root.item.containerHovered
        let childHovered = childPopouts.some(p => p.hoverActive)
        return targetHovered || containerHovered || childHovered
    }

    property Timer hangTimer: Timer {
        interval: 200
        repeat: false
        onTriggered: {
            root.startAnim = false
            cleanupTimer.restart()
        }
    }

    property Timer cleanupTimer: Timer {
        interval: Appearance.anim_fast
        repeat: false
        onTriggered: {
            root.isVisible = false
            root.keepAlive = false
        }
    }

    onHoverActiveChanged: {
        if (hoverActive) {
            hangTimer.stop()
            cleanupTimer.stop()
            root.keepAlive = true
            root.isVisible = true
            root.startAnim = true
        } else {
            hangTimer.restart()
        }
    }

    active: keepAlive

    component: PanelWindow {
        id: popupWindow
        color: "transparent"
        WlrLayershell.namespace: "whisker:popout"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        anchors.top: true
        anchors.left: true
        margins.left: hoverTarget ? hoverTarget.mapToGlobal(Qt.point(0, 0)).x - (Preferences.horizontalBar() ? 20 : -40) : 0
        margins.top: hoverTarget ? hoverTarget.mapToGlobal(Qt.point(0, 0)).y + (Preferences.horizontalBar() ? hoverTarget.height : 0) : 0
        implicitWidth: Math.max(500, container.implicitWidth+20)
        implicitHeight: Math.max(screen.height, container.implicitHeight+20)

        mask: Region {
            x: !root.hasHitbox ? 0 : container.x
            y: !root.hasHitbox ? 0 : container.y
            width: !root.hasHitbox ? 0 : container.implicitWidth
            height: !root.hasHitbox ? 0 : container.implicitHeight
        }

        visible: root.isVisible

        property bool containerHovered: containerMouseArea.containsMouse

        Item {
            id: container
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: root.margin
            implicitWidth: contentArea.implicitWidth + root.margin*2
            implicitHeight: contentArea.implicitHeight + root.margin*2

            opacity: root.startAnim ? 1 : 0
            scale: root.startAnim ? 1 : 0.9
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowOpacity: 1
                shadowColor: Appearance.colors.m3shadow
                shadowBlur: 1
                shadowScale: 1
            }
            Behavior on opacity { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
            Behavior on scale { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
            Behavior on implicitWidth { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }
            Behavior on implicitHeight { NumberAnimation { duration: Appearance.anim_fast; easing.type: Easing.OutExpo } }

            ClippingRectangle {
                id: popupBackground
                anchors.fill: parent
                color: Appearance.colors.m3surface
                radius: 10

                ColumnLayout {
                    id: contentArea
                    anchors.fill: parent
                    anchors.margins: root.margin
                }
            }

            MouseArea {
                id: containerMouseArea
                anchors.fill: parent
                hoverEnabled: root.interactable
                propagateComposedEvents: true
                acceptedButtons: Qt.NoButton
            }
        }

        Component.onCompleted: {
            for (let i = 0; i < root.content.length; i++) {
                root.content[i].parent = contentArea
            }

            let parentPopout = root.parent
            while (parentPopout && !parentPopout.childPopouts) {
                parentPopout = parentPopout.parent
            }
            if (parentPopout) {
                parentPopout.childPopouts.push(root)
            }
        }
    }
}
