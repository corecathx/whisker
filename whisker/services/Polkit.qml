pragma Singleton
pragma ComponentBehavior: Bound

import Quickshell
import Quickshell.Io
import Quickshell.Services.Polkit
import QtQuick

Singleton {
    id: root

    property alias isActive: polkit.isActive
    property alias isRegistered: polkit.isRegistered
    property alias flow: polkit.flow
    property alias path: polkit.path

    Component.onCompleted: {
    }
    PolkitAgent {
        id: polkit
    }
}
