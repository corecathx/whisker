import QtQuick
import QtQuick.Layouts
import qs.components
import qs.modules

Item {
    id: root
    property bool shouldAnimateHeight: true
    property bool shouldShowOsd: false
    property string iconName: ""
    property string label: ""
    property string valueText: ""
    property real fillValue: 0.0
    property int iconSize: 32
    property int autoHideDelay: 3000

    visible: opacity > 0
    implicitHeight: shouldShowOsd ? 50 : shouldAnimateHeight ? 0.0 : 50
    implicitWidth: shouldShowOsd ? 200 : 0.0
    scale: shouldShowOsd ? 1 : 0.9
    opacity: shouldShowOsd ? 1 : 0.0
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
        }
    }
    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
        }
    }

    Behavior on scale {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    Timer {
        id: hideTimer
        interval: root.autoHideDelay
        onTriggered: root.shouldShowOsd = false
    }

    function show() {
        root.shouldShowOsd = true
        hideTimer.restart()
    }

    Rectangle {
        anchors.fill: parent
        radius: Appearance.rounding.medium
        color: Appearance.colors.m3surface

        RowLayout {
            anchors {
                fill: parent
                leftMargin: 5
                rightMargin: 5
            }
            spacing: 6

            MaterialIcon {
                icon: root.iconName
                font.pixelSize: root.iconSize
                color: Appearance.colors.m3on_background
            }

            ColumnLayout {
                Layout.fillWidth: true
                implicitHeight: 40
                spacing: 5

                RowLayout {
                    StyledText {
                        color: Appearance.colors.m3on_background
                        text: root.label
                        font.family: "Outfit Medium"
                        font.pixelSize: 14
                        Layout.fillWidth: true
                    }

                    StyledText {
                        color: Appearance.colors.m3on_surface_variant
                        text: root.valueText
                        font.pixelSize: 14
                        visible: root.valueText !== ""
                    }
                }

                StyledProgressBar {
                    implicitHeight: 5
                    fill: root.fillValue
                    gapRadius: 1
                    gap: 4
                }
            }
        }
    }
}
