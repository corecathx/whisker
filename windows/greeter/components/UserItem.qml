import QtQuick
import QtQuick.Layouts
import QtQuick.Effects

import Quickshell
import Quickshell.Widgets

import qs.modules
import qs.components

Item {
    id: item
    required property int index
    required property string modelData
    required property var foregroundLayer

    property bool selected: index == foregroundLayer.selectedUser
    property real targetIndexOffset: index - foregroundLayer.selectedUser

    width: 500
    height: 120

    signal userSelected()

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowOpacity: 0.4
        shadowColor: Appearance.colors.m3shadow
        shadowBlur: 1
    }

    anchors {
        verticalCenter: parent.verticalCenter
        verticalCenterOffset: (height + 20) * targetIndexOffset
        left: parent.left
        margins: 60
        leftMargin: 60 + Math.abs(40 * targetIndexOffset) * -1

        Behavior on leftMargin {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
        Behavior on verticalCenterOffset {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }
    }

    Connections {
        target: root

        function onEnterPressed() {
            if (targetIndexOffset == 0) {
                item.triggerSelected()
            }
        }
    }

    ClippingRectangle {
        id: userBg
        anchors.fill: parent
        color: Appearance.colors.m3surface
        opacity: selected ? 0.8 : 0.6
        radius: height

        Image {
            id: userWallpaperImage

            anchors.fill: parent
            sourceSize: Qt.size(parent.width, parent.height)
            source: Utils.getGreeterWallpaperUserPath(modelData)
            fillMode: Image.PreserveAspectCrop
            smooth: true
            cache: true
            layer.enabled: true

            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: 16
                brightness: -0.2

                layer.enabled: true
                layer.effect: MultiEffect {
                    autoPaddingEnabled: false
                    blurEnabled: true
                    blur: 1
                    blurMax: 16
                }
            }
        }
    }

    RowLayout {
        anchors {
            fill: parent
            margins: 16
        }

        spacing: 20

        ProfileIcon {
            Layout.fillHeight: true
            Layout.preferredWidth: height
            username: modelData
            color: Appearance.colors.m3surface_container_high
        }

        StyledText {
            Layout.fillWidth: true
            text: modelData
            font.pixelSize: 42
            font.bold: true
            elide: Text.ElideRight
        }
    }

    NumberAnimation {
        id: anim
        target: item
        property: "scale"
        from: 0.9
        to: 1
        duration: Appearance.animation.fast
        easing.type: Appearance.animation.easing
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onClicked: () => {
            if (targetIndexOffset == 0) {
                triggerSelected()
            } else {
                foregroundLayer.changeSelectedUser(index, true);
            }
        }
    }

    function triggerSelected() {
        anim.restart()
        item.userSelected()
    }
}