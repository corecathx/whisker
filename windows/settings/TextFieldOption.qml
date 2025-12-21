import QtQuick
import Quickshell
import qs.modules
import QtQuick.Layouts
import qs.components
import qs.preferences

RowLayout {
    id: textOpt
    opacity: visible ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Appearance.animation.medium; easing.type: Appearance.animation.easing } }
    property string title: ""
    property string description: ""
    property string prefField: ""
    property string placeholder: ""
    Layout.fillWidth: true
    spacing: 12
    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2
        StyledText { text: textOpt.title; font.pixelSize: 15; color: Appearance.colors.m3on_surface }
        StyledText { text: textOpt.description; font.pixelSize: 12; color: Colors.opacify(Appearance.colors.m3on_surface, 0.6) }
    }
    Item { Layout.fillWidth: true }
    StyledTextField {
        Layout.alignment: Qt.AlignVCenter
        Layout.preferredWidth: 180
        text: Preferences[textOpt.prefField.split('.')[0]][textOpt.prefField.split('.')[1]]
        placeholderText: textOpt.placeholder
        fieldPadding: 10
        onTextChanged: { Quickshell.execDetached({ command: ['whisker', 'prefs', 'set', textOpt.prefField, text.toString()] }) }
    }
}
