pragma Singleton
import QtQuick
import Quickshell

// think of this like a shared properties across qmls
QtObject {
    function getPath(key) {
        return Quickshell.shellDir + '/' + key
    }
}
