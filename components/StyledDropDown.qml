import Quickshell
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.modules

Item {
    id: root

    property bool compact: false
    implicitWidth: {
        if (!compact)
            return 200

        if (dropdown.popup.visible)
            return popupMaxWidth + horizontalPadding
        else
            return closedWidth + horizontalPadding
    }
    height: 56

    Behavior on implicitWidth {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }
    property int horizontalPadding: 24 + dropdownIcon.implicitWidth
    property int closedWidth: labelText.width + dropdownIcon.implicitWidth
    property int popupMaxWidth: calculatePopupMaxWidth() + 12 + dropdownIcon.implicitWidth

    property alias radius: container.radius
    property string label: "Select option"
    property var model: ["Option 1", "Option 2", "Option 3", "Option 4", "Option 5"]
    property int currentIndex: -1
    property string currentText: currentIndex >= 0 ? model[currentIndex] ?? "" : ""
    property bool enabled: true
    property string tooltipText: ""

    signal selectedIndexChanged(int index)

    function calculatePopupMaxWidth() {
        var max = 0
        for (let i = 0; i < model.length; i++) {
            metrics.text = model[i]
            max = Math.max(max, metrics.width)
        }
        return max
    }

    TextMetrics {
        id: metrics
        font.pixelSize: 16
        font.family: "Outfit"
        font.weight: Font.Normal
    }

    Rectangle {
        id: container
        anchors.fill: parent
        color: "transparent"
        border.color: dropdown.activeFocus
            ? Appearance.colors.m3primary
            : Appearance.colors.m3outline
        border.width: dropdown.activeFocus ? 2 : 1
        radius: 4

        Behavior on border.color {
            ColorAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }

        Behavior on border.width {
            NumberAnimation {
                duration: Appearance.animation.fast
                easing.type: Appearance.animation.easing
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            enabled: root.enabled
            hoverEnabled: true

            onClicked: {
                dropdown.popup.visible
                    ? dropdown.popup.close()
                    : dropdown.popup.open()
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.parent.radius
                color: Appearance.colors.m3primary
                opacity: mouseArea.pressed
                    ? 0.12
                    : mouseArea.containsMouse
                        ? 0.08
                        : 0

                Behavior on opacity {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }
            }
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            // spacing: 12

            StyledText {
                id: labelText
                Layout.alignment: Qt.AlignVCenter
                text: root.currentIndex >= 0 ? root.currentText : root.label
                color: root.currentIndex >= 0
                    ? Appearance.colors.m3on_surface
                    : Colors.opacify(
                          Appearance.colors.m3on_surface_variant,
                          0.7
                      )
                font.pixelSize: 16
                font.family: "Outfit"
                elide: Text.ElideRight
                verticalAlignment: Text.AlignVCenter
            }
            Item { Layout.fillWidth: true; }
            MaterialIcon {
                id: dropdownIcon
                Layout.alignment: Qt.AlignVCenter
                icon: dropdown.popup.visible
                    ? "arrow_drop_up"
                    : "arrow_drop_down"
                font.pixelSize: 20
                color: Appearance.colors.m3on_surface_variant
            }
        }
    }

    ComboBox {
        id: dropdown
        visible: false
        model: root.model
        currentIndex: root.currentIndex
        enabled: root.enabled

        onCurrentIndexChanged: {
            root.currentIndex = currentIndex
            root.selectedIndexChanged(currentIndex)
        }

        popup: Popup {
            y: root.height + 4
            width: root.width
            padding: 0

            background: Rectangle {
                color: Appearance.colors.m3surface_container
                radius: 4
                border.color: Appearance.colors.m3outline
                border.width: 1
                layer.enabled: true
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowColor: Colors.opacify(
                        Appearance.colors.m3shadow,
                        0.25
                    )
                    shadowBlur: 0.4
                    shadowVerticalOffset: 8
                    shadowHorizontalOffset: 0
                }
            }

            contentItem: ListView {
                id: listView
                clip: true
                implicitHeight: contentHeight > 300 ? 300 : contentHeight
                model: dropdown.popup.visible ? dropdown.model : null
                currentIndex: dropdown.currentIndex

                ScrollBar.vertical: ScrollBar {
                    policy: ScrollBar.AsNeeded
                }

                delegate: ItemDelegate {
                    width: listView.width
                    height: 48

                    background: Rectangle {
                        color: {
                            if (itemMouse.pressed)
                                return Colors.opacify(
                                    Appearance.colors.m3primary,
                                    0.12
                                )
                            if (itemMouse.containsMouse)
                                return Colors.opacify(
                                    Appearance.colors.m3primary,
                                    0.08
                                )
                            if (index === root.currentIndex)
                                return Colors.opacify(
                                    Appearance.colors.m3primary,
                                    0.08
                                )
                            return "transparent"
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: Appearance.animation.fast
                                easing.type: Appearance.animation.easing
                            }
                        }
                    }

                    contentItem: StyledText {
                        text: modelData
                        color: index === root.currentIndex
                            ? Appearance.colors.m3primary
                            : Appearance.colors.m3on_surface
                        font.pixelSize: 16
                        font.family: "Outfit"
                        font.weight: Font.Normal
                        verticalAlignment: Text.AlignVCenter
                        leftPadding: 16
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true

                        onClicked: {
                            dropdown.currentIndex = index
                            dropdown.popup.close()
                        }
                    }
                }
            }

            enter: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 0.0
                    to: 1.0
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
                NumberAnimation {
                    property: "scale"
                    from: 0.9
                    to: 1.0
                    duration: Appearance.animation.fast
                    easing.type: Appearance.animation.easing
                }
            }

            exit: Transition {
                NumberAnimation {
                    property: "opacity"
                    from: 1.0
                    to: 0.0
                    duration: Appearance.animation.fast * 0.67
                    easing.type: Appearance.animation.easing
                }
            }
        }
    }

    HoverHandler {
        id: hover
        enabled: root.tooltipText !== "" && !dropdown.popup.visible
    }
    LazyLoader {
        active: root.tooltipText !== "" && !dropdown.popup.visible
        StyledPopout {
            hoverTarget: hover
            hoverDelay: 500
            Component {
                StyledText {
                    text: root.tooltipText
                }
            }
        }
    }
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Space || event.key === Qt.Key_Return) {
            dropdown.popup.visible
                ? dropdown.popup.close()
                : dropdown.popup.open()
            event.accepted = true
        }
    }
}
