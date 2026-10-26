import QtQuick
import qs.whisker.components
import qs.whisker.services

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
