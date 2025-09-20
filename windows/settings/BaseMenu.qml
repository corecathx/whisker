import QtQuick
import Quickshell.Widgets
import Quickshell
import QtQuick.Layouts

import qs.modules
import qs.components
import qs.preferences

Item {
    id: baseMenu
    anchors.fill: parent

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
                Text {
                    text: baseMenu.title
                    font.pixelSize: 24
                    font.bold: true
                    font.family: "Outfit SemiBold"
                    color: Appearance.colors.m3on_background
                }
                Text {
                    text: baseMenu.description
                    font.pixelSize: 14
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }

            Rectangle {
                id: hr
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
            }
        }

        height: headerContent.implicitHeight
    }

    Flickable {
        id: mainScroll
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 20
        anchors.leftMargin: 40
        anchors.rightMargin: 40
        anchors.top: headerArea.bottom
        anchors.bottom: parent.bottom
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        contentWidth: mainContent.width
        contentHeight: mainContent.childrenRect.height + 20

        Item {
            id: mainContent
            width: mainScroll.width

            Column {
                id: stackedSections
                width: parent.width
                spacing: 20
            }
        }
    }
}
