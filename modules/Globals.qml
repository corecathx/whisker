pragma Singleton
import QtQuick

// think of this like a shared properties across qmls
QtObject {
    property bool visible_quickPanel: false
    property bool visible_settingsMenu: false

    signal _toggleQuickPanel()
    signal _toggleSettingsMenu()


    function toggle_quickPanel() {
        visible_quickPanel = !visible_quickPanel
        _toggleQuickPanel()
    }

    function toggle_settingsPanel() {
        visible_settingsMenu = !visible_settingsMenu
        _toggleSettingsMenu()
    }
}
