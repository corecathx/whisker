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
    property int cardMargin: 16
    property int cardSpacing: 8
    property int verticalPadding: 32
    property bool useAnims: false
    Rectangle {
        id: wpBG
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: contentArea.implicitHeight + baseCard.verticalPadding
        Behavior on implicitHeight {
            NumberAnimation {
                duration: !baseCard.useAnims ? 0 : Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        color: Appearance.colors.m3surface_container_low
        Behavior on color {
            ColorAnimation {
                duration: !baseCard.useAnims ? 0 : Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        radius: 18
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
