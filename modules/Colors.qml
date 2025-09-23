pragma Singleton

import QtQuick

QtObject {
    function lighten(color, factor) {
        var hsl = Qt.hsla(color.hslHue, color.hslSaturation, Math.min(1.0, color.hslLightness + factor), color.a)
        return hsl
    }

    function darken(color, factor) {
        var hsl = Qt.hsla(color.hslHue, color.hslSaturation, Math.max(0.0, color.hslLightness - factor), color.a)
        return hsl
    }

    function opacify(color, alpha) {
        return Qt.rgba(color.r, color.g, color.b, alpha)
    }

    function mix(color1, color2, ratio) {
        var r = color1.r + (color2.r - color1.r) * ratio
        var g = color1.g + (color2.g - color1.g) * ratio
        var b = color1.b + (color2.b - color1.b) * ratio
        var a = color1.a + (color2.a - color1.a) * ratio
        return Qt.rgba(r, g, b, a)
    }

    function fromHex(hex) {
        return Qt.color(hex)
    }
}