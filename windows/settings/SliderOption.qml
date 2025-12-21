import QtQuick
import Quickshell
import qs.modules
import qs.preferences
import QtQuick.Layouts
import qs.components

ColumnLayout {
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
     RowLayout {
         ColumnLayout {
             spacing: 2
             StyledText { text: sliderOpt.title; font.pixelSize: 15; color: Appearance.colors.m3on_surface }
             StyledText { text: sliderOpt.description; font.pixelSize: 12; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6) }
         }
         Item { Layout.fillWidth: true }
         StyledText {
             text: actualSlider.value
         }
     }

     StyledSlider {
         id: actualSlider
         Layout.alignment: Qt.AlignVCenter
         value: Preferences[sliderOpt.prefField.split('.')[0]][switchOpt.prefField.split('.')[1]]
         onMoved: {
             Quickshell.execDetached({ command: ['whisker', 'prefs', 'set', sliderOpt.prefField, value] })
         }
     }
 }
