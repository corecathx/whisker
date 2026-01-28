pragma ComponentBehavior: Bound;
import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Services.Pipewire
import qs.components
import qs.modules
import qs.services

Item {
    id: root
    property bool noMixer: false
    property real volume: Audio.defaultSink?.audio?.muted ? 0 : (Audio.defaultSink?.audio?.volume ?? 0) * 100
    property string icon: volume > 50 ? "volume_up" : volume > 0 ? "volume_down" : 'volume_off'

    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight
    visible: icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    component AudioSlider: Item {
        id: slider
        required property PwNode node
        property string label: ""
        property string iconName: ""
        property bool useMaterialIcon: false

        implicitWidth: 300
        implicitHeight: layout.height

        PwObjectTracker {
            objects: [slider.node]
        }

        RowLayout {
            id: layout
            anchors.centerIn: parent
            width: Math.min(parent.width, 350)
            spacing: 8

            MaterialIcon {
                visible: slider.useMaterialIcon
                icon: slider.iconName
                font.pixelSize: 30
                color: Appearance.colors.m3on_surface
            }

            IconImage {
                visible: !slider.useMaterialIcon
                source: slider.iconName
                implicitWidth: 30
                implicitHeight: 30
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                RowLayout {
                    spacing: 8
                    Layout.fillWidth: true

                    StyledText {
                        text: slider.label
                        color: Appearance.colors.m3on_surface
                        font.pixelSize: 14
                        font.family: "Outfit Medium"
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    StyledText {
                        text: slider.node?.audio?.muted ? "Muted" : Math.floor((slider.node?.audio?.volume ?? 0) * 100) + "%"
                        color: Appearance.colors.m3on_surface
                        font.pixelSize: 12
                    }
                }

                StyledSlider {
                    Layout.fillWidth: true
                    implicitHeight: 30
                    implicitWidth: 240
                    from: 0
                    to: 1
                    enabled: slider.node?.ready ?? false
                    value: slider.node?.audio?.volume ?? 0
                    onValueChanged: {
                        if (slider.node?.ready && slider.node?.audio) {
                            slider.node.audio.volume = value
                        }
                    }
                }

                StyledText {
                    visible: text !== ""
                    text: {
                        if (!slider.node?.properties) return ""
                        let p = slider.node.properties
                        let title = p["media.title"] || ""
                        let artist = p["media.artist"] || ""
                        let media = p["media.name"] || ""
                        if (title && artist) return `${title} - ${artist}`
                        if (title) return title
                        if (media) return media
                        return ""
                    }
                    color: Appearance.colors.m3on_surface
                    opacity: 0.7
                    font.pixelSize: 11
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }
        }
    }

    MouseArea {
        id: mA
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Quickshell.execDetached({
                command: ['whisker', 'ipc', 'settings', 'open', 'sounds']
            })
        }
    }

    HoverHandler { id: hover }

    StyledPopout {
        id: popout
        hoverTarget: hover
        hCenterOnItem: true
        interactable: true
        Component {
            ColumnLayout {
                spacing: 5
                AudioSlider {
                    visible: Audio.defaultSink
                    node: Audio.defaultSink
                    label: Audio.defaultSink?.nickname || Audio.defaultSink?.description || "Output"
                    iconName: root.icon
                    useMaterialIcon: true
                }
                Rectangle {
                    visible: !root.noMixer
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 8
                    height: 1
                    color: Appearance.colors.m3on_surface_variant
                    opacity: 0.2
                }
                Repeater {
                    visible: !root.noMixer
                    model: Audio.outputAppNodes.filter(node => {
                        let name = (node.properties?.["node.name"] || "").toLowerCase()
                        return true
                    })
                    delegate: AudioSlider {
                        required property var modelData
                        Layout.topMargin: 2
                        Layout.bottomMargin: 4
                        node: modelData
                        label: {
                            return Audio.appNodeDisplayName(modelData)
                        }
                        iconName: {
                            let p = modelData.properties
                            if (!p) return ""

                            let appIcon = Audio.appNodeDisplayName(modelData)
                            if (appIcon) {
                                let resolved = Utils.getAppIcon(appIcon, "")
                                if (resolved && !resolved.includes("image-missing"))
                                    return resolved
                            }

                            let nodeName = p["node.name"] || ""
                            if (nodeName) {
                                let resolved = Utils.getAppIcon(nodeName, "")
                                if (resolved && !resolved.includes("image-missing"))
                                    return resolved
                            }

                            return ""
                        }
                        useMaterialIcon: false
                    }
                }
                Rectangle {
                    visible: !root.noMixer
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.bottomMargin: 4
                    height: 1
                    color: Appearance.colors.m3on_surface_variant
                    opacity: 0.2
                }
                RowLayout {
                    Layout.fillWidth: true
                    StyledButton {
                        Layout.fillHeight: true
                        implicitWidth: 30
                        implicitHeight: 30
                        icon: !Audio.defaultSink?.audio.muted ? "volume_up" : "volume_off"
                        checkable: true
                        onToggled: {
                            if (!Audio.defaultSink) return;
                            Audio.defaultSink.audio.muted = !checked
                        }
                        Layout.fillWidth: true
                        topRightRadius: 10
                        bottomRightRadius: 10
                        tooltipText: !Audio.defaultSink?.audio.muted ? "Mute audio" : "Unmute audio"
                    }
                    StyledButton {
                        text: "Sounds Settings"
                        Layout.fillWidth: true
                        secondary: true
                        topLeftRadius: 10
                        bottomLeftRadius: 10
                        onClicked: {
                            mA.onClicked(null)
                            popout.hide()
                        }
                    }
                }
            }
        }
    }

    RowLayout {
        id: container
        MaterialIcon {
            font.pixelSize: 20
            icon: root.icon
            color: Appearance.colors.m3on_background
        }
    }
}
