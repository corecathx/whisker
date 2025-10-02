import QtQuick
import QtQuick.Layouts
import qs.modules

Item {
    id: baseCard
    anchors.left: parent.left
    anchors.right: parent.right
    implicitHeight: wpBG.implicitHeight

    default property alias content: contentArea.data
    property alias color: wpBG.color
    property alias radius: wpBG.radius
    property int cardMargin: 20
    property int cardSpacing: 10
    property int verticalPadding: 40
    property bool useAnims: false

    Rectangle {
        id: wpBG
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: contentArea.implicitHeight + baseCard.verticalPadding
        Behavior on implicitHeight {
            NumberAnimation {
                duration: !baseCard.useAnims ? 0 : Appearance.anim_fast
                easing.type: Easing.OutCubic
            }
        }
        color: Appearance.colors.m3surface_container_low
        Behavior on color {
            ColorAnimation {
                duration: !baseCard.useAnims ? 0 : Appearance.anim_fast
                easing.type: Easing.OutCubic
            }
        }
        radius: 20
    }

    ColumnLayout {
        id: contentArea
        anchors.top: wpBG.top
        anchors.left: wpBG.left
        anchors.right: wpBG.right
        anchors.margins: baseCard.cardMargin
        spacing: baseCard.cardSpacing
    }
}
