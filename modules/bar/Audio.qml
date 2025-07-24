// TimeLabel.qml
import Quickshell
import QtQuick.Layouts
import QtQuick
import Quickshell.Io
import Quickshell.Services.Pipewire
import qs.components
import qs.modules
Item {
    id: root

    property string icon
    implicitWidth: container.implicitWidth
    implicitHeight: container.implicitHeight

    visible: icon !== ""
    Layout.preferredWidth: visible ? implicitWidth : 0
    Layout.preferredHeight: visible ? implicitHeight : 0

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }

    RowLayout {
        id: container
        MaterialSymbol {
            id: icon
            font.pixelSize: 20
            property real volume: Pipewire.defaultAudioSink?.audio.muted ? 0 : Pipewire.defaultAudioSink?.audio.volume*100
            icon: volume > 50 ? "volume_up" : volume > 0 ? "volume_down" : 'volume_off' 
            color: Colors.foreground
        }
    }
}
