import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.whisker.modules
import qs.whisker.components
import qs.whisker.components.animation

StyledRectangle {
    id: root

    required property var modelData

    readonly property string commitHash: modelData.sha ?? ""
    readonly property string commitMessage: (modelData.commit?.message ?? "No commit message").split("\n")[0]
    readonly property string authorName: modelData.commit?.author?.name ?? "Unknown author"
    readonly property string authorLogin: modelData.author?.login ?? ""
    readonly property string avatarUrl: authorLogin !== ""
        ? "https://github.com/" + authorLogin + ".png"
        : ""
    readonly property date commitDate: new Date(modelData.commit?.author?.date ?? "")
    readonly property int daysAgo: isNaN(commitDate.getTime()) ? -1 : Math.max(0, Math.floor((new Date().setHours(0, 0, 0, 0) - new Date(commitDate.getFullYear(), commitDate.getMonth(), commitDate.getDate()).getTime()) / 86400000))
    readonly property string dateLabel: {
        if (daysAgo < 0) return "Unknown date"
        if (daysAgo === 0) return "Today"
        if (daysAgo === 1) return "Yesterday"
        return daysAgo + " days ago"
    }

    color: itemMouseArea.containsMouse
        ? Appearance.colors.m3surface_container_highest
        : Appearance.colors.m3surface_container_high

    radius: Appearance.rounding.small
    implicitHeight: itemLayout.implicitHeight + 24

    Behavior on color {
        ColorAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    RowLayout {
        id: itemLayout

        anchors {
            fill: parent
            margins: 12
        }

        spacing: 12

        ClippingRectangle {
            Layout.preferredWidth: 60
            Layout.preferredHeight: 60
            radius: height
            color: Appearance.colors.m3surface_container_highest

            MaterialIcon {
                anchors.centerIn: parent
                icon: "person"
                color: Appearance.colors.m3on_surface_variant
            }

            Image {
                anchors.fill: parent
                source: root.avatarUrl
                sourceSize: Qt.size(80, 80)
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: true
                visible: status === Image.Ready
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            StyledText {
                Layout.fillWidth: true
                text: root.commitMessage
                font.pixelSize: 18
                font.bold: true
                color: Appearance.colors.m3on_surface
                elide: Text.ElideRight
                maximumLineCount: 1
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                StyledText {
                    text: root.authorLogin !== "" ? "@" + root.authorLogin : root.authorName
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                    elide: Text.ElideRight
                    Layout.maximumWidth: 180
                }

                StyledText {
                    text: "·"
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                }

                StyledText {
                    text: root.commitHash.substring(0, 7)
                    font.family: "monospace"
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                }

                StyledText {
                    text: "·"
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                }

                StyledText {
                    text: isNaN(root.commitDate.getTime())
                        ? "Unknown date"
                        : Qt.formatDate(root.commitDate, "MMM dd, yyyy")
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                }

                StyledText {
                    visible: !isNaN(root.commitDate.getTime())
                    text: "·"
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                }

                StyledText {
                    visible: !isNaN(root.commitDate.getTime())
                    text: root.dateLabel
                    font.pixelSize: 12
                    color: Appearance.colors.m3on_surface_variant
                }
            }
        }

        MaterialIcon {
            icon: "open_in_new"
            color: Appearance.colors.m3on_surface_variant
        }
    }

    MouseArea {
        id: itemMouseArea

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            Qt.openUrlExternally("https://github.com/corecathx/whisker/commit/" + root.commitHash)
        }
    }
}