import QtQuick
import QtQuick.Layouts
import qs.modules

Item {
    id: baseMenu
    anchors.fill: parent
    property bool startAnim: false
    Component.onCompleted: {
        Qt.callLater(() => {
            baseMenu.startAnim = true;
        });
    }
    opacity: startAnim ? 1 : 0
    scale: startAnim ? 1 : 0.95
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
        anchors.topMargin: 30
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        width: parent.width
        ColumnLayout {
            id: headerContent
            visible: false
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 8
            ColumnLayout {
                StyledText {
                    text: baseMenu.title
                    font.pixelSize: 22
                    font.bold: true
                    font.family: "Outfit SemiBold"
                    color: Appearance.colors.m3on_background
                }
                StyledText {
                    text: baseMenu.description
                    font.pixelSize: 13
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
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 30
        anchors.rightMargin: 30
        anchors.topMargin: 16
        clip: true
        interactive: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        contentHeight: mainContent.childrenRect.height + 16
        contentWidth: width
        Item {
            id: mainContent
            width: mainScroll.width
            height: mainContent.childrenRect.height
            Column {
                id: stackedSections
                width: Math.min(mainScroll.width, 1000)
                x: (mainContent.width - width) / 2
                spacing: 16
            }
        }
    }
}
