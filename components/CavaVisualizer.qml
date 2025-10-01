import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.preferences
import qs.modules

Item {
    id: root
    width: 400
    height: 200
    property real multiplier: 1.2
    property real spacing: 8
    property string position: "bottom"
    Row {
        visible: Preferences.cavaEnabled
        id: visualizerLayout
        anchors.fill: parent
        spacing: root.spacing

        Repeater {
            model: Cava.values.length

            Rectangle {
                width: Math.max(1,(visualizerLayout.width - ((Cava.values.length - 1) * visualizerLayout.spacing)) / Cava.values.length)
                height: Math.max(1, Cava.values[index] * multiplier)
                color: Colors.opacify(Appearance.colors.m3on_background, 0.3)
                anchors.bottom: position === "bottom" ? parent.bottom : undefined
                anchors.top: position === "top" ? parent.top : undefined
            }
        }
    }
}
