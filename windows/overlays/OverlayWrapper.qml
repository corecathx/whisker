import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.preferences
import qs.components
import qs.services
import qs.modules

Scope {
    id: root

    // TODO: move StatsOverlay to this.
    LazyLoader {
        active: true

        PanelWindow {
            id: w
            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }
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
                }

                Lyrics {
                    id: lyricsBox
                    visible: Preferences.widgets.showLyrics && Preferences.widgets.lyricsAsOverlay
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 40
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
}
