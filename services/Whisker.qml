pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.modules

Singleton {
    function notify(title, body) {
        Quickshell.execDetached({
            command: ["whisker", "notify", title, body]
        });
    }
}