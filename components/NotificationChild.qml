import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import qs.modules
import qs.components
import qs.preferences

Rectangle {
    id: root

    property string title: "Notification"
    property string body: ""
    property string image: ""
    property var notifData: null
    property var buttons: []

    property bool animateEntry: false
    property bool expanded: false
    property var colors: {
        return {
            vDefault: {
                normal: Appearance.colors.m3surface_container,
                hovered: Appearance.colors.m3surface_container_high,
                pressed: Appearance.colors.m3surface_container_low,
                onsurface: Appearance.colors.m3on_surface
            },
            vCritical: {
                normal: Appearance.colors.m3secondary_container,
                hovered: Colors.lighten(Appearance.colors.m3secondary_container, 0.1),
                pressed: Colors.darken(Appearance.colors.m3secondary_container, 0.1),
                onsurface: Appearance.colors.m3on_secondary_container
            }
        }
    }
    property var currentColors: colors[root.notifData.urgency == NotificationUrgency.Critical ? "vCritical" : "vDefault"]
    property color bgDefault: currentColors.normal
    property color bgHovered: currentColors.hovered
    property color bgPressed: currentColors.pressed
    radius: Appearance.rounding.medium
    implicitHeight: content.implicitHeight + 20
    color: hovered ? (!pressed ? bgHovered : bgPressed) : bgDefault

    property bool hovered: hover.hovered
    property bool pressed: mouseHandler.pressed

    x: animateEntry ? Preferences.bar.position === "right" ? -width : width : 0
    Component.onCompleted: {
        x = 0;
    }

    Behavior on x {
        NumberAnimation {
            duration: Appearance.animation.normal
            easing.type: Appearance.animation.easing
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }

    MouseArea {
        id: mouseHandler
        property int startY

        anchors.fill: parent
        cursorShape: root.buttons.length === 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        preventStealing: true

        drag.target: root
        drag.axis: Drag.XAxis

        onEntered: {
            if (root.notifData?.timer) {
                root.notifData.timer.stop();
            }
        }

        onExited: {
            if (!pressed && root.notifData?.timer) {
                root.notifData.timer.start();
            }
        }

        onPressed: mouse => {
            if (root.notifData?.timer) {
                root.notifData.timer.stop();
            }
            startY = mouse.y;

            if (mouse.button === Qt.MiddleButton) {
                root.notifData?.dismiss();
            }
        }

        onReleased: mouse => {
            if (!containsMouse && root.notifData?.timer) {
                root.notifData.timer.start();
            }

            if (Math.abs(root.x) < root.width * 0.5) {
                root.x = 0;
            } else {
                root.notifData?.dismiss();
            }
        }

        onPositionChanged: mouse => {
            if (pressed) {
                const diffY = mouse.y - startY;
                if (Math.abs(diffY) > 20) {
                    root.expanded = diffY > 0;
                }
            }
        }

        onClicked: mouse => {
            if (mouse.button !== Qt.LeftButton) {
                return;
            }

            if (root.buttons.length === 1) {
                root.buttons[0].onClick();
                root.notifData?.dismiss();
            } else if (root.buttons.length === 0) {
                root.notifData?.dismiss();
            }
        }
    }
    RowLayout {
        id: content
        anchors {
            fill: parent
            margins: 10
        }
        spacing: 10

        Item {
            Layout.preferredWidth: 50
            Layout.preferredHeight: 50
            Layout.alignment: Qt.AlignTop

            ClippingRectangle {
                anchors.fill: parent
                radius: Appearance.rounding.large
                color: root.image === "" ? currentColors.hovered: "transparent"

                Image {
                    anchors.fill: parent
                    source: root.image
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    visible: root.image !== ""
                }

                MaterialIcon {
                    icon: "notifications"
                    color: currentColors.onsurface
                    anchors.centerIn: parent
                    visible: root.image === ""
                    font.pixelSize: 28
                }
            }
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            Layout.topMargin: 5
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                StyledText {
                    text: root.title
                    font.bold: true
                    font.pixelSize: 16
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    color: currentColors.onsurface
                    maximumLineCount: root.expanded ? -1 : 1
                    elide: root.expanded ? Text.ElideNone : Text.ElideRight
                }
                StyledText {
                    Layout.alignment: Qt.AlignVCenter
                    color: Appearance.colors.m3on_surface_variant
                    text: root.notifData.timeStr
                    font.pixelSize: 12
                }
            }

            StyledText {
                text: root.body
                visible: root.body.length > 0
                font.pixelSize: 13
                color: Appearance.colors.m3on_surface_variant
                wrapMode: Text.Wrap
                Layout.fillWidth: true
                maximumLineCount: root.expanded ? -1 : 1
                elide: root.expanded ? Text.ElideNone : Text.ElideRight
            }

            RowLayout {
                visible: root.buttons.length > 0
                Layout.fillWidth: true
                Layout.topMargin: 5
                spacing: 8

                Repeater {
                    model: Math.min(root.buttons.length, 3)

                    StyledButton {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        text: root.buttons[index].label
                        topRightRadius: index === 0 ? 5 : 100
                        bottomRightRadius: index === 0 ? 5 : 100
                        topLeftRadius: index === root.buttons.length - 1 ? 5 : 100
                        bottomLeftRadius: index === root.buttons.length - 1 ? 5 : 100
                        secondary: index !== 0

                        onClicked: {
                            root.buttons[index].onClick();
                            root.notifData?.dismiss();
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.alignment: expandButt.visible && !root.expanded ? Qt.AlignVCenter : Qt.AlignTop
            spacing: 4

            StyledButton {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                implicitWidth: 24
                implicitHeight: 24
                icon: "close"
                icon_size: 18
                text: ""
                base_bg: "transparent"
                base_fg: Appearance.colors.m3on_surface_variant
                hover_bg: Appearance.colors.m3surface_container_highest
                pressed_bg: Appearance.colors.m3surface_container_high
                onClicked: {
                    root.notifData?.dismiss();
                }
            }

            StyledButton {
                id: expandButt
                visible: root.body.length > 100 || root.title.length > 50
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                implicitWidth: 24
                implicitHeight: 24
                icon: root.expanded ? "expand_less" : "expand_more"
                icon_size: 18
                text: ""
                base_bg: "transparent"
                base_fg: Appearance.colors.m3on_surface_variant
                hover_bg: Appearance.colors.m3surface_container_highest
                pressed_bg: Appearance.colors.m3surface_container_high
                onClicked: {
                    root.expanded = !root.expanded;
                }
            }
        }
    }

    HoverHandler {
        id: hover
    }
}
