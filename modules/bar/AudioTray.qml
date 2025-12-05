pragma ComponentBehavior: Bound;
import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.components
import qs.modules
import qs.services
Item {
    id: root
    property real volume: Audio.defaultSink?.audio.muted ? 0 : Audio.defaultSink?.audio.volume*100
    property string icon: volume > 50 ? "volume_up" : volume > 0 ? "volume_down" : 'volume_off'
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    visible: icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached({
                command: ['whisker', 'ipc', 'settings', 'open', 'sounds']
            })
        }
    }
    HoverHandler {
        id: hover
    }
    StyledPopout {
        hoverTarget: hover
        hCenterOnItem: true
        Component {
            RowLayout {
                MaterialIcon {
                    icon: root.icon
                    font.pixelSize: 22
                    color: Appearance.colors.m3on_surface

                }
                ColumnLayout {
                    spacing: 0
                    StyledText {
                        text: {
                            return Audio.defaultSink.description
                        }
                        color: Appearance.colors.m3on_surface
                        font.pixelSize: 14
                    }
                    StyledText {
                        text: {
                            if (Audio.defaultSink?.audio.muted)
                                return "Muted"
                            return Math.floor(Audio.defaultSink?.audio.volume * 100) + "%"
                        }
                        color: Appearance.colors.m3on_surface
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
    RowLayout {
        id: container
        MaterialIcon {
            id: icon
            font.pixelSize: 20
            icon: root.icon
            color: Appearance.colors.m3on_background
        }
    }
}
