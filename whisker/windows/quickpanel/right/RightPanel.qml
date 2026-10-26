import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import qs.whisker.modules
import qs.whisker.services
import qs.whisker.components
import qs.whisker.components.effects
import qs.whisker.components.misc
import qs.whisker.preferences
import qs.whisker.modules.bar
import Quickshell.Hyprland

Scope {
    id: root
    property bool opened: false

    IpcHandler {
        target: "rightpanel"
        function toggle() {
            root.opened = !root.opened;
        }
    }

    CustomShortcut {
        name: "rightpanel"
        description: "Toggle Whisker's Right Panel."

        onReleased: () => {
            root.opened = !root.opened;
        }
    }

    LazyLoader {
        active: root.opened

        PanelWindow {
            id: window
            anchors {
                top: true
                bottom: true
                right: true
            }
            margins {
                top: -10
                bottom: -10
                right: -10
                left: -10
            }

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.namespace: "whisker:rightpanel"
            exclusionMode: ExclusionMode.Normal

            implicitWidth: 460 + 20
            implicitHeight: 670 + 20
            color: 'transparent'

            Item {
                anchors.fill: parent
                layer.enabled: true
                layer.effect: BaseShadow {}

                StyledRectangle {
                    id: bg
                    anchors.fill: parent
                    color: Appearance.panel_color
                    radius: 20
                    anchors.margins: 20
                }
                ColumnLayout {
                    anchors.centerIn: parent
                    MaterialIcon { 
                        Layout.alignment: Qt.AlignHCenter
                        icon: 'construction'
                        size: 72
                        color: Appearance.colors.m3on_surface_variant
                    }
                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: "Work in progress!"
                        font.family: "Outfit Black"
                        font.pixelSize: 32
                    }
                }
            }

            HyprlandFocusGrab {
                id: grab
                windows: [window]
            }

            onVisibleChanged: {
                if (visible)
                    grab.active = true;
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active) {
                        root.opened = false;
                    }
                }
            }
        }
    }
}
