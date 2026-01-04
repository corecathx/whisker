import QtQuick
import Quickshell
import qs.modules
import qs.preferences
import QtQuick.Layouts
import qs.components

RowLayout {
     id: switchOpt
     opacity: visible ? 1 : 0
     Behavior on opacity { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
     property string title: ""
     property string description: ""
     property string prefField: ""
     Layout.fillWidth: true
     spacing: 12
     ColumnLayout {
         spacing: 2
         StyledText { text: switchOpt.title; font.pixelSize: 15; color: Appearance.colors.m3on_surface }
         StyledText { text: switchOpt.description; font.pixelSize: 12; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6); wrapMode: Text.Wrap; Layout.fillWidth: true}
     }
     Item { Layout.fillWidth: true }
     StyledSwitch {
         Layout.alignment: Qt.AlignVCenter
         checked: Preferences[switchOpt.prefField.split('.')[0]][switchOpt.prefField.split('.')[1]]
         onToggled: { Quickshell.execDetached({ command: ['whisker', 'prefs', 'set', switchOpt.prefField, checked] }) }
     }
 }
