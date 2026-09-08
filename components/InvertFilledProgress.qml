import QtQuick
import QtQuick.Layouts
import qs.modules

StyledClippingRectangle {
    id: ifProgress

    property real value: 0.0
    property real maxValue: 100.0
    property string icon: ""
    property string text: ""
    property string smallText: value + "%"

    property color mainColor: Appearance.colors.m3primary
    property color secondaryColor: Appearance.colors.m3primary_container
    property color tertiaryColor: mainColor

    Layout.fillWidth: true
    height: 60

    color: ifProgress.secondaryColor
    radius: Appearance.rounding.medium

    IfpContent {
        anchors.fill: parent
        icon: ifProgress.icon
        text: ifProgress.text
        smallText: ifProgress.smallText
        color: ifProgress.mainColor
    }

    StyledClippingRectangle {
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }

        width: parent.width * (ifProgress.value / ifProgress.maxValue)

        color: ifProgress.tertiaryColor

        IfpContent {
            width: ifProgress.width
            height: ifProgress.height
            icon: ifProgress.icon
            text: ifProgress.text
            smallText: ifProgress.smallText
            color: ifProgress.mainColor
        }
    }
    component IfpContent: Item {
        id: ifpc

        property real margin: 8.0
        property string icon: ""
        property string text: ""
        property string smallText: ""
        property real value: 0.0
        property real maxValue: 100.0
        property color color: Appearance.colors.m3primary

        RowLayout {
            x: ifpc.margin
            y: ifpc.margin

            MaterialIcon {
                icon: ifpc.icon
                color: ifpc.color
            }

            StyledText {
                font.pixelSize: 16
                font.family: "JetBrainsMono Nerd Font"
                font.weight: 700
                text: ifpc.text
                color: ifpc.color
            }
        }

        RowLayout {
            x: ifpc.width - width - ifpc.margin
            y: ifpc.height - height - ifpc.margin

            StyledText {
                font.pixelSize: 14
                font.family: "JetBrainsMono Nerd Font"
                text: ifpc.smallText
                color: ifpc.color
            }
        }
    }
}