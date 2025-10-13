import QtQuick
import QtQuick.Layouts
import qs.modules
import qs.components

SetupPage {
    id: root

    property string title: ""
    property string description: ""
    property bool canContinue: false
    property string blockedMessage: "Please complete this step before continuing"

    signal nextRequested()
    signal backRequested()

    default property alias content: contentArea.data

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 40
        spacing: 10

        ColumnLayout {
            spacing: 5

            StyledText {
                text: root.title
                color: Appearance.colors.m3on_surface
                font.pixelSize: 28
                font.family: "Outfit SemiBold"
            }

            StyledText {
                text: root.description
                color: Appearance.colors.m3on_surface_variant
                font.pixelSize: 13
                font.family: "Outfit"
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Colors.opacify(Appearance.colors.m3on_surface, 0.4)
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: contentArea.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: contentArea
                width: parent.width
                spacing: 16
            }
        }

        RowLayout {
            visible: !root.canContinue
            spacing: 8
            Layout.fillWidth: true

            MaterialIcon {
                icon: "warning"
                color: Appearance.colors.m3error
                font.pixelSize: 18
            }

            StyledText {
                text: root.blockedMessage
                color: Appearance.colors.m3error
                font.pixelSize: 12
                font.family: "Outfit"
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            spacing: 10

            StyledButton {
                text: "Back"
                secondary: true
                onClicked: root.backRequested()
            }

            StyledButton {
                text: "Next"
                enabled: root.canContinue
                onClicked: {
                    if (root.canContinue) {
                        root.nextRequested()
                    }
                }
            }
        }
    }
}
