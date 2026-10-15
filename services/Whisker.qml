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
    
    function setPrefs(key, value) {
        Log.info('services/Whisker.qml', 'setting preferences "' + key + '" to "' + value + '"');
        Quickshell.execDetached({
            command: ['whisker', 'prefs', 'set', key, value]
        })
    }
}