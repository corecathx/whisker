import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import qs.modules
import qs.components
import qs.services

Item {
    id: root
    property bool showLabel: true
    property bool verticalMode: false
    property int padding: 8

    Layout.preferredWidth: verticalMode ? container.implicitWidth : showLabel ? container.implicitWidth : 0
    Layout.preferredHeight: verticalMode ? (showLabel ? container.implicitHeight : 0) : container.implicitHeight
    width: container.implicitWidth + (root.padding * 2)
    height: container.implicitHeight
    opacity: showLabel ? 1 : 0

    StyledRectangle {
        color: Appearance.colors.m3surface_container
        anchors.fill: parent
        radius: Appearance.rounding.large
        
    }

    Column {
        spacing: verticalMode ? -2 : -5
        id: container
        anchors.horizontalCenter: parent.horizontalCenter

        Column {
            spacing: -2
            anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined

            StyledText {
                text: verticalMode ? Qt.formatDateTime(Time.date, "HH") : Qt.formatDateTime(Time.date, "HH:mm")
                color: Appearance.colors.m3on_surface
                font.pixelSize: 18
                font.family: "Outfit ExtraBold"
                lineHeight: 0.1
                anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined
            }

            StyledText {
                visible: verticalMode
                text: Qt.formatDateTime(Time.date, "mm")
                color: Appearance.colors.m3on_surface
                font.pixelSize: 18
                font.family: "Outfit ExtraBold"
                font.bold: true
                lineHeight: 0.1
                anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined
            }
        }

        StyledText {
            text: verticalMode ? Qt.formatDateTime(Time.date, "dd/MM") : Qt.formatDateTime(Time.date, "ddd, dd/MM")
            color: Appearance.colors.m3on_surface_variant
            font.pixelSize: 12
            lineHeight: 0.1
            anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined

        }
    }

    Behavior on Layout.preferredWidth {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
    Behavior on Layout.preferredHeight {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
    Behavior on opacity {
        NumberAnimation { duration: Appearance.animation.fast; easing.type: Appearance.animation.easing }
    }
    HoverHandler {
        id: hover
    }

    MouseArea {
        id: mArea
        anchors.fill: parent
        hoverEnabled: true

        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (popout.isVisible)
                popout.hide()
            else
                popout.show()
        }
    }
    StyledPopout {
        id: popout
        hoverTarget:hover
        interactable: true
        hCenterOnItem: true
        requiresHover: false
        Component {
            Item {
                implicitWidth: 300
                implicitHeight: content.height + 10

                ColumnLayout {
                    id: content
                    anchors.centerIn: parent
                    width: parent.width - 10
                    RowLayout {
                        spacing: 8
                        MaterialIcon {
                            color: Appearance.colors.m3primary
                            icon: {
                                const hour = Time.hours

                                if (hour >= 5 && hour < 17)
                                    return "sunny"
                                else if (hour >= 17 && hour < 21)
                                    return "wb_twilight"
                                else
                                    return "dark_mode"
                            }

                            size: 32
                        }
                        ColumnLayout {
                            spacing: 0
                            StyledText {
                                text: Qt.formatDateTime(Time.date, "HH:mm")
                                color: Appearance.colors.m3on_surface
                                font.pixelSize: 24
                                font.family: "Outfit ExtraBold"
                                anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined
                            }
                            StyledText {
                                text: Qt.formatDateTime(Time.date, "dddd, dd/MM/yyyy")
                                color: Appearance.colors.m3on_surface
                                font.pixelSize: 14
                                anchors.horizontalCenter: verticalMode ? parent.horizontalCenter : undefined
                            }
                            
                        }
                    }
                    StyledRectangle {
                        Layout.fillWidth: true
                        height: 1
                        color: Appearance.colors.m3surface_variant
                    }
                    Calendar {
                        Layout.fillWidth: true
                    }
                }
            }
        }
    }
}
