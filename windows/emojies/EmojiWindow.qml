import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Hyprland as Hypr
import Quickshell.Wayland
import Quickshell.Io

import qs.modules
import qs.services
import qs.preferences
import qs.components
import qs.components.misc

import qs.windows.emojies.components

Scope {
    id: root

    property bool opened: false
    property var emojies: []
    property var recentEmojies: Preferences.misc.recentEmojies
    property var selectedEmoji: null
    property var categories: [
        { name: 'Recent', icon: 'history' },
        { name: 'Smileys & Emotion', icon: 'mood' },
        { name: 'People & Body', icon: 'sentiment_satisfied' },
        { name: 'Animals & Nature', icon: 'pets' },
        { name: 'Food & Drink', icon: 'restaurant' },
        { name: 'Travel & Places', icon: 'travel_explore' },
        { name: 'Activities', icon: 'sports_soccer' },
        { name: 'Objects', icon: 'lightbulb' },
        { name: 'Symbols', icon: 'favorite' },
        { name: 'Flags', icon: 'flag' }
    ]

    IpcHandler {
        target: 'emoji'

        function toggle() {
            root.shortcutTriggered()
        }
    }

    CustomShortcut {
        name: 'emoji'
        appid: 'whisker'
        description: "Toggle Whisker's emoji panel."

        onReleased: () => root.shortcutTriggered()
    }

    function shortcutTriggered() {
        root.opened = !root.opened
        root.selectedEmoji = null
    }

    function copyEmoji(emoji) {
        Preferences.misc.recentEmojies = [
            emoji,
            ...Preferences.misc.recentEmojies.filter(item => item.emoji !== emoji.emoji)
        ].slice(0, 30)
        Whisker.setPrefs('misc.recentEmojies', JSON.stringify(Preferences.misc.recentEmojies));

        Quickshell.execDetached(['wl-copy', emoji.emoji])
        root.opened = false
    }

    LazyLoader {
        active: root.opened

        PanelWindow {
            id: win

            implicitWidth: 400 + 20
            implicitHeight: 450 + 20
            color: 'transparent'
            WlrLayershell.namespace: 'whisker:dock'
            WlrLayershell.layer: WlrLayer.Overlay
            exclusionMode: ExclusionMode.Normal
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            Hypr.HyprlandFocusGrab {
                id: grab
                windows: [win]
            }

            onVisibleChanged: {
                if (visible) {
                    grab.active = true;
                    searchField.text = "";
                    searchField.focus = true;
                    root.selectedEmoji = null
                }
            }

            Connections {
                target: grab
                function onActiveChanged() {
                    if (!grab.active)
                        root.opened = false;
                }
            }

            function getEmojis(categoryName) {
                const query = searchField.text.trim().toLowerCase()
                    .replace(/^:+|:+$/g, '')
                    .replace(/_/g, ' ')
                const source = categoryName === 'Recent'
                    ? root.recentEmojies
                    : root.emojies.filter(emoji => emoji.category === categoryName)

                return source?.filter(emoji => {
                    if (query === '')
                        return true

                    if (Utils.fuzzyMatch(emoji.description.toLowerCase(), query))
                        return true

                    if ((emoji.aliases || []).some(alias =>
                        Utils.fuzzyMatch(alias.toLowerCase().replace(/_/g, ' '), query)))
                        return true

                    if ((emoji.tags || []).some(tag =>
                        Utils.fuzzyMatch(tag.toLowerCase().replace(/_/g, ' '), query)))
                        return true

                    return false
                })
            }

            function getAllEmojis() {
                const result = []

                root.categories.forEach(category => {
                    getEmojis(category.name).forEach(emoji => {
                        result.push({ category: category.name, emoji: emoji })
                    })
                })

                return result
            }

            function moveSelection(key) {
                const emojis = getAllEmojis()

                if (emojis.length === 0)
                    return

                let index = emojis.findIndex(item =>
                    root.selectedEmoji
                    && item.category === root.selectedEmoji.category
                    && item.emoji.emoji === root.selectedEmoji.emoji
                )

                const columns = Math.max(1, Math.floor(emojiList.width / 50))

                if (index < 0) {
                    index = key === Qt.Key_Left || key === Qt.Key_Up
                        ? emojis.length - 1
                        : 0
                } else if (key === Qt.Key_Left) {
                    index = Math.max(0, index - 1)
                } else if (key === Qt.Key_Right) {
                    index = Math.min(emojis.length - 1, index + 1)
                } else if (key === Qt.Key_Up) {
                    index = Math.max(0, index - columns)
                } else if (key === Qt.Key_Down) {
                    index = Math.min(emojis.length - 1, index + columns)
                }

                root.selectedEmoji = {
                    category: emojis[index].category,
                    emoji: emojis[index].emoji.emoji
                }

                const categoryIndex = root.categories.findIndex(
                    category => category.name === emojis[index].category
                )

                if (categoryIndex >= 0)
                    emojiList.positionViewAtIndex(categoryIndex, ListView.Contain)
            }

            Item {
                anchors {
                    fill: parent
                    margins: 20
                }

                StyledRectangle {
                    anchors.fill: parent
                    color: Appearance.colors.m3surface
                    radius: Appearance.rounding.large
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowColor: Appearance.colors.m3shadow
                        shadowBlur: 1
                    }
                }

                ColumnLayout {
                    anchors {
                        fill: parent
                        margins: 20
                    }
                    spacing: 10

                    ListView {
                        id: categoryTabs
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        orientation: ListView.Horizontal
                        spacing: 8
                        clip: true
                        model: root.categories

                        delegate: EmojiCategory {

                        }
                        WheelHandler {
                            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad

                            onWheel: event => {
                                const delta = event.pixelDelta.x !== 0
                                    ? event.pixelDelta.x
                                    : event.pixelDelta.y !== 0
                                        ? event.pixelDelta.y
                                        : event.angleDelta.y / 120 * 50

                                categoryTabs.contentX = Math.max(
                                    0,
                                    Math.min(
                                        categoryTabs.contentWidth - categoryTabs.width,
                                        categoryTabs.contentX - delta
                                    )
                                )

                                event.accepted = true
                            }
                        }
                    }

                    StyledTextField {
                        id: searchField
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        fieldPadding: 10
                        icon: 'search'
                        focus: true
                        placeholderText: 'Search emoji...'

                        onTextChanged: {
                            root.selectedEmoji = null
                            emojiList.positionViewAtBeginning()
                        }

                        Keys.priority: Keys.BeforeItem
                        Keys.onPressed: event => {
                            if (event.key === Qt.Key_Escape) {
                                root.opened = false
                                event.accepted = true
                            } else if (event.key === Qt.Key_Left
                                    || event.key === Qt.Key_Right
                                    || event.key === Qt.Key_Up
                                    || event.key === Qt.Key_Down) {
                                win.moveSelection(event.key)
                                event.accepted = true
                            } else if (event.key === Qt.Key_Return
                                    || event.key === Qt.Key_Enter) {
                                const emojis = win.getAllEmojis()

                                if (emojis.length > 0) {
                                    let index = emojis.findIndex(item =>
                                        root.selectedEmoji
                                        && item.category === root.selectedEmoji.category
                                        && item.emoji.emoji === root.selectedEmoji.emoji
                                    )

                                    if (index < 0)
                                        index = 0

                                    root.copyEmoji(emojis[index].emoji)
                                }

                                event.accepted = true
                            }
                        }
                    }

                    ListView {
                        id: emojiList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 0
                        clip: true
                        model: root.categories

                        delegate: EmojiSection {
                            emojis: win.getEmojis(modelData.name)
                        }
                    }
                }
            }
        }
    }

    FileView {
        path: Utils.getPath('data/emoji.json')
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            try {
                root.emojies = JSON.parse(this.text())
            } catch (e) {
                Log.error('windows/emojies/EmojiWindow.qml', 'Failed to load emoji JSON: ' + e)
            }
        }
    }
}