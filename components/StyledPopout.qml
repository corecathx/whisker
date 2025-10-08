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
    
    property HoverHandler hoverTarget
    property real margin: 10
    default property list<Component> content
    property bool startAnim: false
    property bool isVisible: false
    property bool keepAlive: false
    property bool interactable: false
    property bool hasHitbox: true
    property bool hCenterOnItem: false
    property bool followMouse: false
    property list<StyledPopout> childPopouts: []

    property bool targetHovered: hoverTarget && hoverTarget.hovered
    property bool containerHovered: interactable && root.item && root.item.containerHovered
    property bool selfHovered: targetHovered || containerHovered
    
    property bool childrenHovered: {
        for (let i = 0; i < childPopouts.length; i++) {
            if (childPopouts[i].selfHovered) return true
        }
        return false
    }

    property bool hoverActive: selfHovered || childrenHovered

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
        visible: root.isVisible
        
        WlrLayershell.namespace: "whisker:popout"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        exclusiveZone: 0
        
        anchors {
            left: true
            top: true
            right: true
            bottom: true
        }
        
        implicitWidth: screen.width
        implicitHeight: screen.height

        property bool exceedingHalf: false
        property var parentPopoutWindow: null
        property point mousePos: Qt.point(0, 0)
        property bool containerHovered: root.interactable && containerHoverHandler.hovered
        
        HoverHandler {
            id: windowHover
            onPointChanged: (point) => {
                if (root.followMouse) {
                    popupWindow.mousePos = point.position
                }
            }
        }

        mask: Region {
            x: !root.hasHitbox ? 0 : container.x
            y: !root.hasHitbox ? 0 : container.y
            width: !root.hasHitbox ? 0 : container.implicitWidth
            height: !root.hasHitbox ? 0 : container.implicitHeight
        }

        Item {
            id: container
            
            implicitWidth: contentArea.implicitWidth + root.margin * 2
            implicitHeight: contentArea.implicitHeight + root.margin * 2
            
            x: {
                if (root.followMouse)
                    return mousePos.x + 10

                let targetItem = hoverTarget?.parent
                if (!targetItem)
                    return 0

                let baseX = targetItem.mapToGlobal(Qt.point(0, 0)).x
                if (parentPopoutWindow)
                    baseX += parentPopoutWindow.x

                let targetWidth = targetItem.width
                let popupWidth = container.implicitWidth

                if (root.hCenterOnItem) {
                    let centeredX = baseX + (targetWidth - popupWidth) / 2

                    if (centeredX + popupWidth > screen.width)
                        centeredX = screen.width - popupWidth - 10
                    if (centeredX < 10)
                        centeredX = 10

                    return centeredX
                }

                let xPos = baseX - (Preferences.horizontalBar() ? 20 : -40)

                if (xPos + popupWidth > screen.width) {
                    exceedingHalf = true
                    return baseX - popupWidth
                }

                exceedingHalf = false
                return xPos
            }

            y: {
                if (root.followMouse) return mousePos.y + 10
                
                let targetItem = hoverTarget?.parent
                if (!targetItem) return 0
                
                let yPos = targetItem.mapToGlobal(Qt.point(0, 0)).y
                if (parentPopoutWindow) yPos += parentPopoutWindow.y
                
                return yPos + (Preferences.horizontalBar() ? targetItem.height : 0)
            }

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
            
            Behavior on opacity { 
                NumberAnimation { 
                    duration: Appearance.anim_fast
                    easing.type: Easing.OutExpo 
                } 
            }
            Behavior on scale { 
                NumberAnimation { 
                    duration: Appearance.anim_fast
                    easing.type: Easing.OutExpo 
                } 
            }
            Behavior on implicitWidth { 
                NumberAnimation { 
                    duration: Appearance.anim_fast
                    easing.type: Easing.OutExpo 
                } 
            }
            Behavior on implicitHeight { 
                NumberAnimation { 
                    duration: Appearance.anim_fast
                    easing.type: Easing.OutExpo 
                } 
            }

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

            HoverHandler {
                id: containerHoverHandler
                enabled: root.interactable
            }
        }

        Component.onCompleted: {
            for (let i = 0; i < root.content.length; i++) {
                const comp = root.content[i];
                if (comp && comp.createObject) {
                    comp.createObject(contentArea);
                } else {
                    console.warn("StyledPopout: Invalid content, expected Component:", comp);
                }
            }

            let parentPopout = root.parent;
            while (parentPopout && !parentPopout.childPopouts) {
                parentPopout = parentPopout.parent;
            }
            if (parentPopout) {
                parentPopout.childPopouts.push(root);
                if (parentPopout.item)
                    popupWindow.parentPopoutWindow = parentPopout.item;
            }
        }
    }
}