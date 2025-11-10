import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Widgets
import qs.modules
import qs.preferences
import qs.services

Item {
    id: contributionCalendar
    width: contentThing.width
    height: contentThing.height

    property var contribs: Github.contributions ?? []

    function contributionColor(level) {
        if (level === 0) return Appearance.colors.m3surface_container;
        if (level === 1) return Appearance.colors.m3secondary_container;
        if (level === 2) return Appearance.colors.m3secondary;
        if (level === 3) return Appearance.colors.m3primary;
        return Appearance.colors.m3primary;
    }
    ColumnLayout {
        id: contentThing
        spacing: 10
        RowLayout {
            spacing: 2
            ClippingRectangle {
                width: 20
                height: 20
                color: Appearance.colors.m3surface_container
                IconImage {
                    source: "https://github.com/" + Preferences.misc.githubUsername + ".png"
                    anchors.fill: parent
                }
                radius: 20
            }
            Item {}
            StyledText {
                text: "@" + Preferences.misc.githubUsername
                font.family: "Outfit SemiBold"
                font.pixelSize: 12
            }
            StyledText { text: "•"; font.pixelSize: 10; color: Appearance.colors.m3on_surface_variant}
            StyledText {
                text: Github.contributionNumber
                font.pixelSize: 10
                font.family: "Outfit SemiBold"

                color: Appearance.colors.m3on_surface_variant
            }
            StyledText {
                text: "contributions in the last year"
                font.pixelSize: 10
                color: Appearance.colors.m3on_surface_variant
            }
            Item { Layout.fillWidth: true }
            LoadingIcon {
                size: 20
                visible: !Github.loaded
            }
        }

        GridLayout {
            Layout.alignment: Qt.AlignHCenter
            rows: 7
            columns: 40
            rowSpacing: 2
            columnSpacing: 2

            RowLayout {
                spacing: 3

                Repeater {
                    model: 40
                    delegate: ColumnLayout {
                        spacing: 3

                        property int weekIndex: index

                        Repeater {
                            model: 7
                            delegate: Rectangle {
                                width: 7
                                height: 7
                                radius: 2

                                property int realIndex: weekIndex * 7 + index
                                color: contributionColor(contribs[realIndex]?.level || 0)
                                Behavior on color { ColorAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing } }
                                MouseArea {
                                    id: infoMouseArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    // StyledToolTip {
                                    //     content: `${contribs[realIndex]?.count || 0} commits on ${contribs[realIndex]?.date || "unknown"}`
                                    //     extraVisibleCondition: infoMouseArea.containsMouse
                                    // }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
