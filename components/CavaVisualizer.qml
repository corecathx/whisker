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
    property real multiplier: 1.3
    property real spacing: 8
    property string position: "bottom"

    readonly property int barCount: Cava.values.length
    readonly property real barWidth: barCount > 0 ?
        Math.max(1, (width - ((barCount - 1) * spacing)) / barCount) : 1

    Item {
        id: visualizerLayout
        visible: Preferences.misc.cavaEnabled
        anchors.fill: parent

        Repeater {
            model: root.barCount

            Rectangle {
                required property int index

                x: index * (root.barWidth + root.spacing)
                y: root.position === "bottom" ? root.height - height : 0

                width: root.barWidth
                height: {
                    if (!root.visible) return 0;
                    const value = Cava.values[index] || 0;
                    return Math.max(1, value * root.multiplier);
                }

                color: Colors.opacify(Appearance.colors.m3primary, 0.3)
            }
        }
    }
}
