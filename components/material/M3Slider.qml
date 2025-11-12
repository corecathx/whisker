pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.modules

Slider {
    id: root

    property real trackHeightDiff: 15
    property real handleGap: 6
    property real trackDotSize: 4
    property real trackNearHandleRadius: 2
    property bool useAnim: true

    Layout.fillWidth: true

    implicitWidth: 200
    implicitHeight: 40
    from: 0
    to: 100
    value: 0
    stepSize: 0
    snapMode: stepSize > 0 ? Slider.SnapAlways : Slider.NoSnap

    // Behavior on value {
    //     enabled: !root.pressed
    //     NumberAnimation {
    //         duration: !root.useAnim ? 0 : Appearance.animation.fast
    //         easing.type: Appearance.animation.easing
    //     }
    // }

    component TrackDot: Rectangle {
        required property int index
        property real stepValue: root.from + (index * root.stepSize)
        property real normalizedValue: (stepValue - root.from) / (root.to - root.from)
        anchors.verticalCenter: parent.verticalCenter
        x: root.handleGap + (normalizedValue * (root.width - root.handleGap * 2)) - root.trackDotSize / 2
        width: root.trackDotSize
        height: root.trackDotSize
        radius: root.trackDotSize / 2
        visible: index > 0 && index < (root.to - root.from) / root.stepSize
        color: normalizedValue > root.visualPosition ? Appearance.colors.m3on_secondary_container : Appearance.colors.m3on_primary

        Behavior on color {
            ColorAnimation {
                duration: !root.useAnim ? 0 : Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: (mouse) => mouse.accepted = false
        cursorShape: root.pressed ? Qt.ClosedHandCursor : Qt.PointingHandCursor
    }

    background: Item {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: parent.height

        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.left
            }
            width: root.handleGap + (root.visualPosition * (root.width - root.handleGap * 2)) - ((root.pressed ? 1.5 : 3) / 2 + root.handleGap)
            height: root.height - root.trackHeightDiff
            color: Appearance.colors.m3primary
            radius: 10
            topRightRadius: root.trackNearHandleRadius
            bottomRightRadius: root.trackNearHandleRadius


            Behavior on width {
                NumberAnimation {
                    duration: !root.useAnim ? 0 : Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
        }

        Rectangle {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
            }
            width: root.handleGap + ((1 - root.visualPosition) * (root.width - root.handleGap * 2)) - ((root.pressed ? 1.5 : 3) / 2 + root.handleGap)
            height: root.height - root.trackHeightDiff
            color: Appearance.colors.m3secondary_container
            radius: 10

            topLeftRadius: root.trackNearHandleRadius
            bottomLeftRadius: root.trackNearHandleRadius
            Behavior on width {
                NumberAnimation {
                    duration: !root.useAnim ? 0 : Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }
        }

        Repeater {
            model: root.stepSize > 0 ? Math.floor((root.to - root.from) / root.stepSize) + 1 : 0
            TrackDot {
                required property int modelData
                index: modelData
            }
        }
    }

    handle: Rectangle {
        width: 5
        height: root.height
        x: root.handleGap + (root.visualPosition * (root.width - root.handleGap * 2)) - width / 2
        anchors.verticalCenter: parent.verticalCenter
        radius: width / 2
        color: Appearance.colors.m3primary

        Behavior on x {
            NumberAnimation {
                duration: !root.useAnim ? 0 : Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
    }
}
