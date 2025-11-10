pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import qs.modules
Item {
    id: root

    anchors.fill: parent

    Rectangle {
        anchors.fill: parent
        color: Appearance.panel_color

        layer.enabled: true
        layer.effect: MultiEffect {
            maskSource: mask
            maskEnabled: true
            maskInverted: true
            maskThresholdMin: 0.5
            maskSpreadAtMin: 1
        }
    }

    Item {
        id: mask

        anchors.fill: parent
        layer.enabled: true
        visible: false

        Rectangle {
            anchors.fill: parent
            anchors.margins: 10
            anchors.topMargin: 0
            radius: 20
        }
    }
}
