import QtQuick
import Quickshell
import qs.whisker.modules

Behavior {
    id: root

    enum Type {
        Number,
        Color,
        Spring
    }

    property int type: Anim.Number
    property int duration: Appearance.animation.medium
    property int easing: Appearance.animation.easing

    property real spring: 4
    property real damping: 0.3
    property real mass: 1.4

    animation: {
        switch (type) {
        case Anim.Number: return numberAnimation
        case Anim.Color: return colorAnimation
        case Anim.Spring: return springAnimation
        default: return null
        }
    }

    property NumberAnimation numberAnimation: NumberAnimation {
        duration: root.duration
        easing.type: root.easing
    }

    property ColorAnimation colorAnimation: ColorAnimation {
        duration: root.duration
        easing.type: root.easing
    }

    property SpringAnimation springAnimation: SpringAnimation {
        spring: root.spring
        damping: root.damping
        mass: root.mass
    }
}