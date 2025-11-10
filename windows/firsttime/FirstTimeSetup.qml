pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import qs.modules
import qs.preferences
import qs.components

FloatingWindow {
    id: window
    color: 'transparent'
    property var screen: Quickshell.screens[0]
    // right: true
    // bottom: true
    //anchors {}
    visible: true
    title: "Whisker Setup"
    property real margin: 0
    width: 760 + margin * 2
    height: 600 + margin * 2

    onClosed: {
        Quickshell.execDetached({
            command: ['whisker', 'prefs', 'set', 'misc.finishedSetup', 'true']
        });
        Quickshell.execDetached({
            command: ['whisker', 'notify', 'Whisker', 'Setup skipped! You can tweak settings anytime with SUPER + I']
        });
        Qt.exit(0)
    }

    Item {
        anchors.fill: parent
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Appearance.colors.m3shadow
            shadowBlur: 1.0
        }

        Rectangle {
            id: bgRectangle
            color: Appearance.colors.m3surface
            anchors.fill: parent
            anchors.margins: window.margin
            radius: 20
        }

        SetupPageContainer {
            id: setupContainer
            anchors.fill: bgRectangle

            WelcomePage {
                onNextRequested: setupContainer.nextPage()
                onQuitRequested: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'misc.finishedSetup', 'true']
                    });
                    Quickshell.execDetached({
                        command: ['whisker', 'notify', 'Whisker', 'Setup skipped! You can tweak settings anytime with SUPER + I', 'true']
                    });
                    Qt.exit(0)
                }
            }

            WallpaperPage {
                onNextRequested: setupContainer.nextPage()
                onBackRequested: setupContainer.previousPage()
            }

            ColorsPage {
                onNextRequested: setupContainer.nextPage()
                onBackRequested: setupContainer.previousPage()
            }

            BarPage {
                onNextRequested: setupContainer.nextPage()
                onBackRequested: setupContainer.previousPage()
            }

            FinishPage {
                onCloseRequested: {
                    Quickshell.execDetached({
                        command: ['whisker', 'prefs', 'set', 'misc.finishedSetup', 'true']
                    });
                    Quickshell.execDetached({
                        command: ['whisker', 'notify', 'Whisker', 'Awesome! Hope you enjoy this shell :]']
                    });
                    Qt.exit(0)
                }
            }
        }

        Row {
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 40
            }
            spacing: 8

            Repeater {
                model: setupContainer.pageCount

                delegate: Rectangle {
                    required property int index

                    width: index === setupContainer.currentIndex ? 16 : 8
                    height: 8
                    radius: 8
                    color: Appearance.colors.m3primary
                    opacity: index === setupContainer.currentIndex ? 1 : 0.3

                    Behavior on width {
                        NumberAnimation {
                            duration: Appearance.animation.medium
                            easing.type: Appearance.animation.easing
                        }
                    }
                }
            }
        }
    }

    component SetupPageContainer: Item {
        property int currentIndex: 0
        property int pageCount: children.length

        function nextPage() {
            if (currentIndex < pageCount - 1)
                currentIndex++;
        }

        function previousPage() {
            if (currentIndex > 0)
                currentIndex--;
        }

        onCurrentIndexChanged: {
            for (let i = 0; i < children.length; i++) {
                children[i].visible = (i === currentIndex);
            }
        }

        Component.onCompleted: {
            for (let i = 0; i < children.length; i++) {
                children[i].visible = (i === 0);
            }
        }
    }
}
