import QtQuick
import QtQuick.Layouts
import qs.whisker.modules

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
    Flickable {
        id: mainScroll
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.rightMargin: 0
        anchors.topMargin: 0
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
            ColumnLayout {
                id: stackedSections
                width: Math.min(mainScroll.width, 1000)
                x: (mainContent.width - width) / 2
                spacing: 16
            }
        }
    }
}
