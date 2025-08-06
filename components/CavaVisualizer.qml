import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.services
import qs.modules

Item {
    id: root
    width: 400
    height: 200
    property real multiplier: 1
    Row {
        id: visualizerLayout
        anchors.fill: parent
        anchors.margins: 0
        spacing: 10

        Repeater {
            model: Cava.values.length

            Rectangle {
                width: (visualizerLayout.width - ((Cava.values.length - 1) * visualizerLayout.spacing)) / Cava.values.length
                height: Math.max(1, Cava.values[index]) * multiplier
                color: Colors.opacify(Colors.foreground, 0.1)
                anchors.bottom: parent.bottom
            }
        }
    }
}
