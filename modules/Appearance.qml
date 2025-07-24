pragma Singleton
import QtQuick 2.15

QtObject {
    property real panel_opacity: 0.7
    property color panel_color: Colors.opacify(Colors.background, panel_opacity)
}