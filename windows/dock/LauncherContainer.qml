import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

import Quickshell
import Quickshell.Widgets

import qs.modules
import qs.components
import qs.preferences
import qs.services

import qs.windows.dock.components

Item {
    id: root

    required property var window
    property real targetHeight: 600

    property var categories: ({
        "AudioVideo": { icon: "play_circle", label: "Multimedia" },
        "Development": { icon: "code", label: "Development" },
        "Education": { icon: "school", label: "Education" },
        "Game": { icon: "sports_esports", label: "Games" },
        "Graphics": { icon: "palette", label: "Graphics" },
        "Network": { icon: "language", label: "Internet" },
        "Office": { icon: "work", label: "Office" },
        "Settings": { icon: "settings", label: "Settings" },
        "System": { icon: "computer", label: "System" },
        "Utility": { icon: "build", label: "Utilities" },
        "Other": { icon: "category", label: "Miscellaneous" },
    })
    property string selectedCategory: ''
    
    property bool sidebarOpened: Preferences.widgets.dock.launcher.showSidebar
    property bool gridView: Preferences.widgets.dock.launcher.gridView

    property int selectedIndex: 0

    signal launcherItemClicked(var item);

    clip: true
    Layout.fillWidth: true
    Layout.topMargin: 5
    implicitHeight: win.state == 1 ? targetHeight : 0
    visible: implicitHeight > 0
    Behavior on implicitHeight {
        NumberAnimation {
            duration: Appearance.animation.fast
            easing.type: Appearance.animation.easing
        }
    }
    StyledRectangle {
        anchors.fill: parent
        color: Appearance.colors.m3surface_container
        radius: Appearance.rounding.medium
        visible: false
    }


    RowLayout {
        anchors.fill: parent
        spacing: 5

        RowLayout {
            id: categoryLayout
            Layout.preferredWidth: implicitWidth
            Layout.fillHeight: true
            ListView {
                id: categoryList
                Layout.preferredWidth: root.sidebarOpened ? 200 : 40
                Behavior on Layout.preferredWidth {
                    NumberAnimation {
                        duration: Appearance.animation.fast
                        easing.type: Appearance.animation.easing
                    }
                }
                Layout.fillHeight: true
                Layout.topMargin: 5
                spacing: 4
                model: {
                    let result = [
                        { id: "", icon: "apps", label: "All" }
                    ]

                    for (let key in categories) {
                        result.push({
                            id: key,
                            icon: categories[key].icon,
                            label: categories[key].label
                        })
                    }

                    return result
                }

                delegate: CategoryButton {
                    width: ListView.view.width

                    height: 40
                    required property var modelData

                    icon: modelData.icon
                    text: modelData.label
                    selected: appList.selectedCategory === modelData.id

                    sidebarOpened: appList.sidebarOpened

                    onClicked: appList.selectedCategory = modelData.id
                }
            }
            Item {
                Layout.fillHeight: true
                width: 15
                StyledRectangle {
                    anchors.fill: parent
                    color: Appearance.colors.m3on_surface_variant
                    opacity: sidebarMouseArea.containsMouse ? 0.08 : 0
                    Behavior on opacity {
                        NumberAnimation {
                            duration: Appearance.animation.fast
                            easing.type: Appearance.animation.easing
                        }
                    }
                    topRightRadius: 20
                    bottomRightRadius: 20
                }
                MaterialIcon {
                    anchors.centerIn: parent
                    icon: appList.sidebarOpened ? "chevron_left" : "chevron_right"
                }

                MouseArea {
                    id: sidebarMouseArea
                    anchors.fill: parent
                    hoverEnabled: true

                    onClicked: {
                        Whisker.setPrefs(
                            'widgets.dock.launcher.showSidebar', 
                            !Preferences.widgets.dock.launcher.showSidebar
                        )
                    }
                }
            }
        }
        ColumnLayout {
            id: appListLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            RowLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: 50
                spacing: 5

                StyledTextField {
                    id: searchField
                    Layout.fillWidth: true
                    Layout.preferredHeight: 50
                    radius: Appearance.rounding.extraLarge
                    fieldPadding: 10
                    filled: false
                    icon: "search"
                    placeholder: "Search or type /"

                    Keys.onPressed: event => {
                        const apps = appContainer.filteredApps
                        if (event.key === Qt.Key_Escape) {
                            root.closeLauncher()
                            event.accepted = true
                            return
                        }

                        if (event.key === Qt.Key_Up || event.key === Qt.Key_Down ||
                            event.key === Qt.Key_Left || event.key === Qt.Key_Right ||
                            event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                            if (apps.length === 0) {
                                event.accepted = true
                                return
                            }

                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                if (root.selectedIndex >= 0 && root.selectedIndex < apps.length) {
                                    apps[root.selectedIndex].execute()
                                    root.launcherItemClicked(apps[root.selectedIndex])
                                }
                            } else {
                                const columns = root.gridView
                                    ? Math.max(1, Math.floor(appGrid.width / appGrid.cellWidth))
                                    : 1

                                let index = root.selectedIndex < 0 ? 0 : root.selectedIndex

                                if (event.key === Qt.Key_Up)
                                    index -= root.gridView ? columns : 1
                                else if (event.key === Qt.Key_Down)
                                    index += root.gridView ? columns : 1
                                else if (event.key === Qt.Key_Left)
                                    index--
                                else if (event.key === Qt.Key_Right)
                                    index++

                                root.selectedIndex = Math.max(0, Math.min(index, apps.length - 1))
                            }

                            event.accepted = true
                        }
                    }
                }

                StyledRectangle {
                    Layout.preferredWidth: 50
                    Layout.preferredHeight: 50
                    radius: Appearance.rounding.medium
                    color: {
                        viewSwitchMouseArea.containsMouse && ! viewSwitchMouseArea.pressed
                            ? Appearance.colors.m3surface_container
                            : Appearance.colors.m3surface
                    }

                    MaterialIcon {
                        anchors.centerIn: parent
                        icon: root.gridView ? "grid_view" : "view_list"
                    }

                    MouseArea {
                        id: viewSwitchMouseArea
                        hoverEnabled: true
                        anchors.fill: parent
                        onClicked: {
                            Whisker.setPrefs(
                                'widgets.dock.launcher.gridView', 
                                !Preferences.widgets.dock.launcher.gridView
                            )
                        }
                        cursorShape: Qt.PointingHandCursor
                    }
                }
            }

            Item {
                id: appContainer

                Layout.fillWidth: true
                Layout.fillHeight: true

                property var filteredApps: {
                    let apps = DesktopEntries.applications.values.slice()
                    apps = apps.filter(entry => !entry.noDisplay)

                    if (root.selectedCategory === "Other") {
                        apps = apps.filter(entry =>
                            !entry.categories.some(category => root.categories[category])
                        )
                    } else if (root.selectedCategory !== '') {
                        apps = apps.filter(entry =>
                            entry.categories.includes(root.selectedCategory)
                        )
                    }

                    let query = searchField.text.trim().toLowerCase()
                    if (query !== '') {
                        apps = apps.filter(entry =>
                            Utils.fuzzyMatch(entry.name.toLowerCase(), query)
                        )
                    }

                    return apps.sort((a, b) =>
                        a.name.localeCompare(b.name, Qt.locale().name)
                    )
                }

                ListView {
                    id: appListView
                    anchors.fill: parent
                    clip: true
                    spacing: 10
                    visible: !root.gridView
                    model: parent.filteredApps
                    currentIndex: root.selectedIndex
                    highlightMoveDuration: Appearance.animation.fast
                    delegate: LauncherListItem {
                        width: ListView.view.width
                        selected: ListView.isCurrentItem
                        onClicked: root.launcherItemClicked(modelData)
                    }
                }

                GridView {
                    id: appGrid
                    anchors.fill: parent
                    clip: true
                    visible: root.gridView
                    cellWidth: Math.max(80, Math.floor(width / Math.max(1, Math.floor(width / 100))))
                    cellHeight: 100
                    model: parent.filteredApps
                    currentIndex: root.selectedIndex

                    delegate: LauncherGridItem {
                        width: GridView.view.cellWidth
                        height: GridView.view.cellHeight
                        selected: GridView.isCurrentItem
                        onClicked: root.launcherItemClicked(modelData)
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: parent.filteredApps.length === 0

                    Image {
                        source: Utils.getPath("images/nothing-found.png")
                        sourceSize: Qt.size(150, 150)
                        smooth: true
                        Layout.alignment: Qt.AlignVCenter
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1.0
                            colorizationColor: Appearance.colors.m3on_surface_variant
                        }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: searchField.text.trim() !== ''
                            ? "No applications found"
                            : "No applications"
                        color: Appearance.colors.m3on_surface_variant
                        font.pixelSize: 14
                    }
                }
            }
        }
    }

    function closeLauncher() {
        window.state = 0
        searchField.text = ''
        selectedCategory = ''
        selectedIndex = 0
    }

    function focusToSearch() {
        searchField.focus = true
    }
}