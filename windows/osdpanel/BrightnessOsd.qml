import QtQuick
import qs.components
import qs.services

ProgressOsd {
    id: root

    label: "Brightness"
    valueText: Math.round(Brightness.value * 100) + "%"
    fillValue: Brightness.value
    iconName: Brightness.icon
    iconSize: 32

    Connections {
        target: Brightness

        function onBrightnessChanged(newValue) {
            root.show()
        }
    }
}
