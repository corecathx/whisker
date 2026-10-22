import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.components
import qs.components.animation
import qs.modules

Item {
    id: root
    required property var modelData
    required property string selectedItem
    Component.onCompleted: console.log(selectedItem)
    height: itemLayout.height

    signal itemSelected(var id)

    ColumnLayout {
        id: itemLayout
        width: parent.width
        StyledText {
            text: modelData.title
            font.bold: true
            color: Appearance.colors.m3on_surface_variant
        }
        ClippingRectangle {
            Layout.fillWidth: true
            // Layout.leftMargin: 5
            Layout.preferredHeight: itemsList.contentHeight
            radius: Appearance.rounding.large
            color: 'transparent'

            ListView {
                id: itemsList

                anchors.fill: parent
                model: modelData.items
                spacing: 5
                interactive: false

                delegate: StyledRectangle {
                    id: menuItem

                    required property var modelData
                    readonly property bool selected: modelData.id === root.selectedItem
                    
                    width: ListView.view.width
                    height: 70
                    color: {
                        if (selected) 
                            return Appearance.colors.m3primary_container
                        if (itemMouseArea.containsMouse && !itemMouseArea.pressed) 
                            return Appearance.colors.m3surface_container_high
                        return Appearance.colors.m3surface_container
                    }
                    Anim on color {
                        type: Anim.Color
                        duration: Appearance.animation.fast
                    }
                    radius: Appearance.rounding.extraSmall
                    RowLayout {
                        anchors {
                            fill: parent
                            margins: 10
                        }
                        spacing: 12
                        StyledRectangle {
                            Layout.fillHeight: true
                            Layout.preferredWidth: height
                            color: selected ? Appearance.colors.m3primary : Appearance.colors.m3secondary_container
                            radius: height
                            Anim on color {
                                type: Anim.Color
                                duration: Appearance.animation.fast
                            }
                            MaterialIcon {
                                anchors.centerIn: parent
                                icon: modelData.icon
                                color: selected ? Appearance.colors.m3on_primary : Appearance.colors.m3secondary
                                filled: selected
                                Anim on color {
                                    type: Anim.Color
                                    duration: Appearance.animation.fast
                                }
                            }
                        }
                        ColumnLayout {
                            spacing: 2
                            Layout.fillWidth: true
                            StyledText {
                                Layout.fillWidth: true
                                text: modelData.label
                                font.pixelSize: 16
                                font.bold: true
                                elide: Text.ElideRight
                                color: selected ? Appearance.colors.m3primary : Appearance.colors.m3on_surface
                                Anim on color {
                                    type: Anim.Color
                                    duration: Appearance.animation.fast
                                }
                            }
                            StyledText {
                                Layout.fillWidth: true
                                color: selected ? Colors.opacify(Appearance.colors.m3primary, 0.8) : Appearance.colors.m3on_surface_variant
                                text: modelData.description
                                elide: Text.ElideRight
                                font.pixelSize: 13
                                Anim on color {
                                    type: Anim.Color
                                    duration: Appearance.animation.fast
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: itemMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.itemSelected(modelData.id)
                    }
                }
            }
        }
    }
}