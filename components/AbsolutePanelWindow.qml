import Quickshell

PanelWindow {
    property point position: Qt.point(100, 100);
    exclusionMode: ExclusionMode.Ignore

    anchors {
        left: true
        top: true
    }

    margins {
        left: position.x
        top: position.y
    }
}