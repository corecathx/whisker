import QtQuick
import QtQuick.Layouts
import qs.modules

Item {
    id: baseMenu
    anchors.fill: parent

    opacity: visible ? 1 : 0
    scale: visible ? 1 : 0.95

    Behavior on opacity {
        NumberAnimation {
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
        }
    }
    Behavior on scale {
        NumberAnimation {
            duration: Appearance.animation.medium
            easing.type: Appearance.animation.easing
        }
    }

    property string title: "Settings"
    property string description: ""
    default property alias content: stackedSections.data

    Item {
        id: headerArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        width: parent.width

        ColumnLayout {
            id: headerContent
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 10

            ColumnLayout {
                StyledText {
                    text: baseMenu.title
                    font.pixelSize: 24
                    font.bold: true
                    font.family: "Outfit SemiBold"
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: baseMenu.description
                    font.pixelSize: 14
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }

            Rectangle {
                id: hr
                anchors.left: parent.left
                anchors.right: parent.right
                implicitHeight: 1
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        height: headerContent.implicitHeight
    }

    Flickable {
        id: mainScroll
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: headerArea.bottom
        anchors.bottom: parent.bottom
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        anchors.topMargin: 20
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        contentHeight: mainContent.childrenRect.height + 20
        contentWidth: width

        Item {
            id: mainContent
            width: mainScroll.width
            height: mainContent.childrenRect.height

            Column {
                id: stackedSections
                width: Math.min(mainScroll.width, 1000)
                x: (mainContent.width - width) / 2
                spacing: 20
            }
        }
    }
}
