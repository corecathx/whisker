import QtQuick
import qs.modules
import qs.components
import QtQuick.Layouts

RowLayout {
    id: section
    property string icon: ""
    property string text: ""
    Layout.fillWidth: true
    spacing: 10
    MaterialIcon { icon: section.icon; color: Appearance.colors.m3primary; font.pixelSize: 22 }
    StyledText { text: section.text; font.pixelSize: 17; font.family: "Outfit SemiBold"; color: Appearance.colors.m3on_surface }
}
