pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules
/**
 * Whisker's Configuration file.
 * Valid values are defined by @value keyword.
 */
Singleton {
    id:root

    signal reloaded();
    property bool spawnedWelcome: false
    onReloaded: {
        if (!root.finishedSetup && !root.spawnedWelcome) {
            console.log('what')
            root.spawnedWelcome = true
            Quickshell.execDetached({ command: ['whisker', 'welcome'] })
        }
    }

    /**
     * Internal usage only, defines whether the Preferences has been load or not.
     */
    property bool ready: false

    /**
     * Wallpaper that will be displayed by Whisker.
     * @values string: <Local file path> "/home/corecat/Pictures/wallpaper.jpg"
     * @default string: ""
     */
    property string wallpaper: ""
    /**
     * Position the bar however you like, other UI elements might follow this rule.
     * @values string: "top", "bottom"
     * @default string: "top"
     */
    property string barPosition: "top"

    /**
     * Whether to keep the bar opaque or not.
     * If set to false, the bar will adjust it's transparency, such as on desktop, etc.
     * @values bool: true, false
     * @default bool: true
     */
    property bool keepBarOpaque: true

    /**
     * Whether to use small bar layout.
     * @values bool: true, false
     * @default bool: false
     */
    property bool smallBar: false

    /**
     * Padding for bars (e.g., panel content).
     * This will only take effect if `smallBar` is `true`.
     * @values int (pixels)
     * @default int: 200
     */
    property int barPadding: 200

    /**
     * Whether to display visualizer on the Shell.
     * Setting this to `false` would disable every visualizer on the shell.
     * @values bool: true, false
     * @default bool: true
     */
    property bool cavaEnabled: true

    /**
     * Whether to use video wallpaper instead of static image.
     * Settings this to `true` might impact performance.
     * @values bool: true, false
     * @default bool: false
     */
    property bool useVideoWallpaper: false

    /**
     * Whether to show wallpapers instead of solid color from your color scheme.
     * @values bool: true, false
     * @default bool: true
     */
    property bool useWallpaper: true

    /**
     * Whether to use dark mode colors.
     * @values bool: true, false
     * @default bool: true
     */
    property bool darkMode: true

    /**
     * Set how `Matugen` generates colors.
     * @values string: content, expressive, fidelity, fruit-salad, monochrome, neutral, rainbow, tonal-spot
     * @default string: tonal-spot
     */
    property string colorScheme: "tonal-spot"

    /**
     * Whether to enable notification popups.
     * @values bool: true, false
     * @default bool: true
     */
    property bool notificationEnabled: true

    /**
     * Whether the user has finished setting up whisker.
     * @values bool: true, false
     * @default bool: true
     */
    property bool finishedSetup: false

    Component.onCompleted: {
        fileView.reload()
        root.ready = true
    }
    Process {
        id: exitProc
        command: ['whisker', 'prefs', '--no-prompt']
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                fileView.reload()
            }
        }
    }
    function load(content) {
        const parsed = JSON.parse(content);

        for (const [name, value] of Object.entries(parsed)) {
            if (root.hasOwnProperty(name))
                root[name] = value;
        }
        root.ready = true
        root.reloaded();
    }
    FileView {
        id: fileView
        path: Utils.getConfigRelativePath('preferences.json')
        watchChanges: true
        onFileChanged: {
            console.log("Preferences updated.")
            fileView.reload()
        }
        onLoaded: root.load(text())
    }

    function verticalBar() {
        return root.barPosition === "left" || root.barPosition === "right";
    }
    function horizontalBar() {
        return root.barPosition === "top" || root.barPosition === "bottom";
    }
}
