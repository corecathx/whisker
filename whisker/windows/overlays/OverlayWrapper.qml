import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Wayland

import qs.whisker.preferences
import qs.whisker.components
import qs.whisker.services
import qs.whisker.modules

Scope {
    id: root

    PanelWindow {
        id: w
        anchors {
            left: true
            right: true
            top: true
            bottom: true
        }
        visible: Preferences.widgets.showLyrics && Preferences.widgets.lyricsAsOverlay
            || Preferences.misc.activateLinuxOverlay
            || Preferences.bar.position === "bottom" || Preferences.verticalBar()
        color: "transparent"
        mask: Region {}
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.exclusionMode: ExclusionMode.Ignore

        Item {
            id: itemWrapper
            anchors.fill: parent

            ActivateLinux {
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 50
                anchors.rightMargin: 70
                visible: Preferences.misc.activateLinuxOverlay
            }

            Lyrics {
                id: lyricsBox
                visible: Preferences.widgets.showLyrics && Preferences.widgets.lyricsAsOverlay
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (Globals.dockBottomMargin + 60) + 40
                
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Appearance.colors.m3shadow
                    shadowBlur: 1
                }

                opacity: Globals.dockState != 1
                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }
            }

            PrivacyIndicator {
                id: privacy
                anchors.top: parent.top

                Connections {
                    target: Preferences.bar
                    function onPositionChanged() {
                        privacy.anchors.right = undefined
                        privacy.anchors.left = undefined

                        if (Preferences.bar.position === "right") {
                            privacy.anchors.right = undefined
                            privacy.anchors.left = privacy.parent.left
                        } else {
                            privacy.anchors.right = privacy.parent.right
                            privacy.anchors.left = undefined
                        }

                    }
                }
                anchors.margins: 10
                visible: Preferences.bar.position === "bottom" || Preferences.verticalBar()
            }
        }
    }
}
