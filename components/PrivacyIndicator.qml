import Quickshell
import qs.modules
import qs.services
import qs.components
import QtQuick
import QtQuick.Layouts
Rectangle {
    implicitWidth: layout.width + 10
    implicitHeight: layout.height + 10
    visible: Privacy.hasAnyActiveAccess
    color: Appearance.colors.m3surface
    radius: 20

    RowLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 5

        Repeater {
            model: [
                {
                    icon: "videocam",
                    isActive: Privacy.hasCameraAccess,
                    apps: Privacy.cameraApps,
                    label: "Camera",
                    color: Appearance.colors.m3error,
                    onColor: Appearance.colors.m3on_error,
                },
                {
                    icon: "mic",
                    isActive: Privacy.hasMicrophoneAccess,
                    apps: Privacy.microphoneApps,
                    label: "Microphone",
                    color: Appearance.colors.m3primary,
                    onColor: Appearance.colors.m3on_primary,
                },
                {
                    icon: "screen_share",
                    isActive: Privacy.hasScreenCaptureAccess,
                    apps: Privacy.screenCaptureApps,
                    label: "Screen Capture",
                    color: Appearance.colors.m3tertiary,
                    onColor: Appearance.colors.m3on_tertiary,
                }
            ]

            delegate: Rectangle {
                implicitWidth: 22
                implicitHeight: 22
                visible: modelData.isActive
                color: modelData.color
                radius: 10

                MaterialIcon {
                    anchors.centerIn: parent
                    icon: modelData.icon
                    font.pixelSize: 18
                    color: modelData.onColor
                }

                HoverHandler {
                    id: hoverHandler
                }

                StyledPopout {
                    hoverTarget: hoverHandler
                    Component {
                        StyledText {
                            text: modelData.label + ": " + modelData.apps.join(", ")
                            font.pixelSize: 12
                        }
                    }
                }
            }
        }
    }
}
