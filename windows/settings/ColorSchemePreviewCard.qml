import Quickshell

import QtQuick

import qs.modules
import qs.components

BaseCard {
    id: root
    cardMargin: 4
    verticalPadding: 8
    radius: 4
    property color backgroundColor: Appearance.colors.m3primary
    property color contentColor: Appearance.colors.m3on_primary
    property string text: "Primary"
    color: backgroundColor
    StyledText {
        text: root.text
        font.pixelSize: 10
        color: root.contentColor
    }
}
