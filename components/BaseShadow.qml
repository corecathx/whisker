import QtQuick
import QtQuick.Effects
import qs.modules

Item {
    Component.onCompleted: {
        parent.layer.enabled = true
        parent.layer.effect = effectComponent
    }

    Component {
        id: effectComponent
        MultiEffect {
            shadowEnabled: true
            shadowOpacity: 1
            shadowColor: Appearance.colors.m3shadow
            shadowBlur: 1
            shadowScale: 1
        }
    }
}
