import QtQuick
import Quickshell.Widgets
import Quickshell
import QtQuick.Layouts

import qs.modules
import qs.components
import qs.preferences

BaseMenu {
    title: "Whisker"
    description: "Adjust how Whisker looks like to your preference."
    BaseCard {
        Text {
            text: "Wallpaper"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }
        ClippingRectangle {
            id: wpContainer
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width * 0.8
            height: width * screen.height / screen.width
            radius: 10

            color: Appearance.colors.m3surface_container
            
            MaterialIcon {
                anchors.centerIn: parent
                icon: "wallpaper"
                font.pixelSize: 64
                color: Appearance.colors.m3on_surface_variant
            }

            Image {
                id: wpImage
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                source: wallpaperPath.text
                smooth: true
            }
        }
        Text {
            text: "Wallpaper Path"
            font.pixelSize: 16
            color: Appearance.colors.m3on_background
        }
        StyledTextField {
            anchors.left: parent.left
            anchors.right: parent.right
            id: wallpaperPath
            height: 20
            leftPadding: undefined
            padding: 10
            placeholderText: "/home/" + Quickshell.env("USER") + "/..."
            text: Preferences.wallpaper

            onTextChanged: {
                wpImage.source = text
            }

            onAccepted: {
                Quickshell.execDetached({
                    command:['whisker', 'wallpaper', text]
                })
            }
        }
    }
    BaseCard {
        Text {
            text: "Color variant / scheme"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        Flickable {
            id: schemeFlick
            anchors.left: parent.left
            anchors.right: parent.right
            height: 150
            clip: true
            interactive: true
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.HorizontalFlick

            contentWidth: rowContent.childrenRect.width
            contentHeight: rowContent.childrenRect.height

            RowLayout {
                id: rowContent
                spacing: 10
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.bottom: parent.bottom

                Repeater {
                    model: ['content', 'expressive', 'fidelity', 'fruit-salad', 'monochrome', 'neutral', 'rainbow', 'tonal-spot']
                    delegate: Item {
                        width: 100
                        height: 130
                        property var schemeColor: Appearance.getScheme(modelData)
                        property bool hovered: mouseHover.containsMouse
                        MouseArea {
                            id: mouseHover
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (Preferences.colorScheme === modelData) return
                                Quickshell.execDetached({
                                    command: ['whisker', 'prefs', 'set', 'colorScheme', modelData]
                                })
                            }
                        }
                        Rectangle {
                            anchors.fill: parent
                            radius: 10
                            color: Preferences.colorScheme === modelData
                                ? !hovered ? schemeColor.surface_container_high : schemeColor.surface_container_highest
                                : !hovered ? schemeColor.surface_container : schemeColor.surface_container_high
                            Behavior on color {
                                ColorAnimation {
                                    duration: Appearance.anim_fast
                                    easing.type: Easing.OutCubic
                                }
                            }
                            border.width: Preferences.colorScheme === modelData ? 3 : 1
                            border.color: schemeColor.outline
                            ColumnLayout {
                                anchors.leftMargin: 10
                                anchors.topMargin: 10
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.right: parent.right
                                spacing: 10

                                Text {
                                    text: modelData
                                    font.pixelSize: 14
                                    color: schemeColor.on_surface || "#000000"
                                }
                                ColumnLayout {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    Rectangle {
                                        width: 30
                                        height: 8
                                        radius: 4
                                        color: schemeColor.on_surface || "#000000"
                                    }
                                    Rectangle {
                                        width: 70
                                        height: 8
                                        radius: 4
                                        color: schemeColor.on_surface || "#000000"
                                    }
                                }
                            }
                            Rectangle {
                                id: secPrev
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 10
                                anchors.bottomMargin: 10
                                width: 15
                                height: 15
                                radius: 5
                                color: schemeColor.secondary || "#000000"
                            }
                            Rectangle {
                                anchors.right: secPrev.left
                                anchors.bottom: parent.bottom
                                anchors.rightMargin: 5
                                anchors.bottomMargin: 10
                                width: 15
                                height: 15
                                radius: 5
                                color: schemeColor.primary || "#000000"
                            }
                        }
                    }
                }
            }
        }

        RowLayout {
            ColumnLayout {
                Text {
                    text: "Dark mode"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                Text {
                    text: "Whether to use dark color schemes."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Preferences.darkMode
                onToggled: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'darkMode', checked]
                    })
                }
            }
        }
    }
    BaseCard {
        Text {
            text: "Bar"
            font.pixelSize: 20
            font.bold: true
            color: Appearance.colors.m3on_background
        }

        ColumnLayout {
            Text {
                text: "Position"
                font.pixelSize: 16
                color: Appearance.colors.m3on_background
            }
            RowLayout {
                Repeater {
                    model: ['Left', 'Bottom', 'Top', 'Right']
                    delegate: StyledButton {
                        text: modelData
                        // checkable: true
                        Layout.fillWidth: true
                        implicitWidth: 0
                        checked: Preferences.barPosition === modelData.toLowerCase()
                        onClicked: {
                            Quickshell.execDetached({
                                command: ['whisker', 'prefs', 'set', 'barPosition', modelData.toLowerCase()]
                            })
                        }
                    }
                }
            }
        }
        RowLayout {
            ColumnLayout {
                Text {
                    text: "Keep bar opaque"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                Text {
                    text: "Whether to keep the bar opaque or not\nIf disabled, the bar will adjust it's transparency, such as on desktop, etc."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Preferences.keepBarOpaque
                onToggled: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'keepBarOpaque', checked]
                    })
                }
            }
        }
        RowLayout {
            ColumnLayout {
                Text {
                    text: "Small bar"
                    font.pixelSize: 16
                    color: Appearance.colors.m3on_background
                }
                Text {
                    text: "Whether to use small bar layout.\nThis has no effect on Left and Right bar layout."
                    font.pixelSize: 12
                    color: Colors.opacify(Appearance.colors.m3on_background, 0.6)
                }
            }
            Item {
                Layout.fillWidth: true
            }
            StyledSwitch {
                checked: Preferences.smallBar
                onToggled: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'smallBar', checked]
                    })
                }
            }
        }
    } 
}

