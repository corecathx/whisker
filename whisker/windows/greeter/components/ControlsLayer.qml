import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell

import qs.whisker.modules
import qs.whisker.modules.bar
import qs.whisker.services
import qs.whisker.components

Item {
    id: root

    property bool showSessionDropdown: false
    property alias sessions: sessionDropdown.model
    property alias selectedSession: sessionDropdown.currentIndex

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowOpacity: 1
        shadowColor: Appearance.colors.m3shadow
        shadowBlur: 0.5
    }
    signal selectedIndexChanged(var index)
    Item {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20
        width: controls.width + 10
        height: controls.height + 10
        StyledRectangle {
            anchors.fill: parent
            color: Appearance.colors.m3surface
            radius: Appearance.rounding.extraLarge
        }
        RowLayout {
            id: controls
            anchors.centerIn: parent
            spacing: 5
            StyledDropDown {
                id: sessionDropdown
                visible: root.showSessionDropdown
                opacity: visible ? 1 : 0
                scale: visible ? 1 : 0.9
                Behavior on opacity { NumberAnimation { duration: Appearance.animation.slow; easing.type: Appearance.animation.easing } }
                Behavior on scale { NumberAnimation { duration: Appearance.animation.slow; easing.type: Appearance.animation.easing } }
                height: 30
                radius: 20
                compact: true
                onSelectedIndexChanged: (index) => {
                    root.selectedIndexChanged(index)
                }
                tooltipText: "Session for " + root.curUsername
            }
            StyledButton {
                icon: "power_settings_new"
                secondary: true
                implicitHeight: 32
                onClicked: {
                    Quickshell.execDetached({ command: ["systemctl", "poweroff" ]})
                }
                tooltipText: "Power off"
            }

            StyledButton {
                icon: "restart_alt"
                implicitHeight: 32
                secondary: true
                onClicked: {
                    Quickshell.execDetached({ command: ["systemctl", "reboot" ]})
                }
                tooltipText: "Reboot"
            }
        }
    }

    ColumnLayout {
        visible: false
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            margins: 100
        }

        spacing: -10

        RowLayout {
            StyledText {
                Layout.alignment: Qt.AlignCenter
                text: Qt.formatDateTime(Time.date, "HH")
                font.family: "Outfit Black"
                color: Appearance.colors.m3primary
                font.pixelSize: 96
            }

            StyledText {
                Layout.alignment: Qt.AlignCenter
                text: ":"
                font.family: "Outfit Black"
                color: Appearance.colors.m3error
                font.pixelSize: 96
            }

            StyledText {
                Layout.alignment: Qt.AlignCenter
                text: Qt.formatDateTime(Time.date, "mm")
                font.family: "Outfit Black"
                color: Appearance.colors.m3secondary
                font.pixelSize: 96
            }
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Qt.formatDateTime(Time.date, "ddd, dd MMM, yyyy")
            color: Appearance.colors.m3primary
            font.pixelSize: 32
            font.bold: true
        }
    }

    StyledRectangle {
        id: topBar
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 20
        }
        // color: Appearance.colors.m3surface
        height: topBarLayout.height + 10

        RowLayout {
            id: topBarLayout
            anchors {
                top: parent.top
                left: parent.left
                right: parent.right
            }
            StyledRectangle {
                id: leftSide
                width: leftSideLayout.width + 20
                height: leftSideLayout.height + 6
                color: Appearance.colors.m3surface
                radius: height
                RowLayout {
                    id: leftSideLayout
                    anchors.centerIn: parent
                    spacing: 10
                    TimeLabel {
                    }
                    Stats {}
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledRectangle {
                id: rightSide
                Layout.preferredWidth: rightSideLayout.width + 20
                Layout.fillHeight: true
                color: Appearance.colors.m3surface
                radius: height
                RowLayout {
                    id: rightSideLayout
                    anchors.centerIn: parent
                    spacing: 10
                    AudioTray { noMixer: true; disableSettings: true }
                    NetworkTray { disableSettings: true }
                    BluetoothTray { disableSettings: true }
                    Battery {}
                }

            }
        }
    }
    // Item {
    //     width: things.width + 10
    //     height: things.height + 10
    //     anchors {
    //         right: parent.right
    //         top: parent.top
    //         margins: 20
    //     }
    //     StyledRectangle {
    //         color: Appearance.colors.m3surface
    //         anchors.fill: parent
    //         radius: Appearance.rounding.extraLarge
    //     }
    //     RowLayout {
    //         id: things
    //         anchors.centerIn: parent
    //         spacing: 5

    //         Item {
    //             width: things2.width + 10
    //             height: things2.height + 3
    //             StyledRectangle {
    //                 color: Appearance.colors.m3surface_container
    //                 anchors.fill: parent
    //                 radius: Appearance.rounding.extraLarge
    //             }
    //             RowLayout {
    //                 id: things2
    //                 anchors.centerIn: parent
    //                 spacing: 10

    //                 AudioTray { noMixer: true }
    //                 NetworkTray {}
    //                 BluetoothTray {}
    //             }
    //         }
    //         Battery {}
    //     }
    // }
    // Item {
    //     width: leftSide.width + 10
    //     height: leftSide.height + 10
    //     anchors {
    //         left: parent.left
    //         top: parent.top
    //         margins: 20
    //     }
    //     StyledRectangle {
    //         color: Appearance.colors.m3surface
    //         anchors.fill: parent
    //         radius: Appearance.rounding.extraLarge
    //     }
    //     RowLayout {
    //         id: leftSide
    //         anchors.centerIn: parent
    //         spacing: 10
    //         TimeLabel {}
    //         Stats {}
    //     }
    // }
}