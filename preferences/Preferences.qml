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
    /**
     * Whether to use top / bottom bar layout, other UI elements might follow this rule.
     * @values "top", "bottom"
     */
    property string barPosition: "top"
    /**
     * Duration it takes for Process objects to execute it's command in miliseconds.
     * @values real: 1000, 2000
     */
    property real processUpdateTime: 1000
    
    /**
     * Whether to use small bar layout.
     * @values bool: true, false
     */
    property bool smallBar: false

    /**
     * Padding for bars (e.g., panel content).
     * @values int (pixels)
     */
    property int barPadding: 200

    /**
     * Whether to display visualizer on the Shell.
     * Setting this to `false` would disable every visualizer on the shell.
     * @values bool: true, false
     */
    property bool cavaEnabled: false

    function load(content) { 
        const parsed = JSON.parse(content);

        for (const [name, value] of Object.entries(parsed)) {
            if (root.hasOwnProperty(name))
                root[name] = value;
        }
    }
    FileView {
        path: Utils.getPath('preferences.json')
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text())
    }
}
