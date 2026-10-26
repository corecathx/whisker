import QtQuick

import qs.whisker.modules
Item {
    anchors.fill: parent
    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.9

    Behavior on opacity {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
    Behavior on scale {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
}
