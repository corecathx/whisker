pragma Singleton
import QtQuick
import Quickshell

// think of this like a shared properties across qmls
Singleton {
    property bool isBarHovered: false

    property bool isQuickpanelVisible: false

    property real dockBottomMargin: 0
    property real dockHeight: 0
    property real dockState: 0
}
