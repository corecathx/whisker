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

    property int cardMargin: 20
    property int cardSpacing: 10
    property int radius: 20
    property int verticalPadding: 40

    Rectangle {
        id: wpBG
        anchors.left: parent.left
        anchors.right: parent.right
        implicitHeight: contentArea.implicitHeight + baseCard.verticalPadding
        Behavior on implicitHeight {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        color: Appearance.colors.m3surface_container_low
        Behavior on color {
            ColorAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        radius: baseCard.radius
    }

    RowLayout {
        id: contentArea
        anchors.top: wpBG.top
        anchors.left: wpBG.left
        anchors.right: wpBG.right
        anchors.margins: baseCard.cardMargin
        spacing: baseCard.cardSpacing
    }
}
