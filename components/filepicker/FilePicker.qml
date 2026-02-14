pragma ComponentBehavior: Bound
import qs.components
import qs.services
import qs.modules
import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

//main handler for pickerwindow
QtObject {
    id: root

    property string currentPath: Quickshell.env("HOME")
    property string filterLabel: "All files"
    property list<string> filters: ["*"]
    property string title: "Select a file"

    signal accepted(path: string)
    signal rejected()

    property var windowInstance: null
    property bool opened: windowInstance !== null

    function open(): void {
        if (!windowInstance) {
            windowInstance = windowComponent.createObject(null, {
                currentPath: root.currentPath,
                filterLabel: root.filterLabel,
                filters: root.filters,
                windowTitle: root.title
            });

            windowInstance.accepted.connect(function(path) {
                root.accepted(path);
                closeWindow();
            });

            windowInstance.rejected.connect(function() {
                root.rejected();
                closeWindow();
            });
        }

        windowInstance.visible = true;
        windowInstance.resetState();
    }

    function closeWindow(): void {
        if (windowInstance) {
            windowInstance.visible = false;
            windowInstance.destroy(100);
            windowInstance = null;
        }
    }

    property Component windowComponent: Component {
        PickerWindow {}
    }
}
