pragma Singleton
import QtQuick
import Quickshell

QtObject {
    readonly property string _RESET  : "\x1b[0m"
    readonly property string _GRAY   : "\x1b[90m"
    readonly property string _BLUE   : "\x1b[34m"
    readonly property string _YELLOW : "\x1b[33m"
    readonly property string _RED    : "\x1b[31m"

    function _now() {
        return Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss")
    }

    function _format(levelColor, source, message) {
        return (
            _GRAY + "[" + _now() + " - " +
            _BLUE + source +
            _GRAY + "] " +
            levelColor + message +
            _RESET
        )
    }

    function info(source, message) {
        console.log(_format("", source, message))
    }

    function warn(source, message) {
        console.warn(_format(_YELLOW, source, message))
    }

    function error(source, message) {
        console.error(_format(_RED, source, message))
    }
}
