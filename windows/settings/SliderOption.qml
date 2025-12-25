import QtQuick
import Quickshell
import qs.modules
import qs.preferences
import QtQuick.Layouts
import qs.components

RowLayout {
    id: sliderOpt
    opacity: visible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
    property string title: ""
    property string description: ""
    property string prefField: ""
    property alias from: actualSlider.from
    property alias to: actualSlider.to
    property alias stepSize: actualSlider.stepSize
    Layout.fillWidth: true
    spacing: 12

    ColumnLayout {
        spacing: 2
        StyledText { text: sliderOpt.title; font.pixelSize: 15; color: Appearance.colors.m3on_surface }
        StyledText { text: sliderOpt.description; font.pixelSize: 12; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6) }
    }

    Item { Layout.fillWidth: true }

    RowLayout {
        Layout.alignment: Qt.AlignVCenter
        spacing: 10

        StyledSlider {
            id: actualSlider
            Layout.preferredWidth: 180
            Layout.fillWidth: false
            value: Preferences[sliderOpt.prefField.split('.')[0]][sliderOpt.prefField.split('.')[1]]
            onMoved: {
                Quickshell.execDetached({ command: ['whisker', 'prefs', 'set', sliderOpt.prefField, value] })
            }
        }

        StyledText {
            text: Math.round(actualSlider.value)
            font.pixelSize: 14
            color: Appearance.colors.m3on_surface
            Layout.preferredWidth: 30
            horizontalAlignment: Text.AlignRight
        }
    }
}
