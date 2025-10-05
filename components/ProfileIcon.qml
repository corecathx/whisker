import Quickshell.Widgets
import qs.modules

ClippingRectangle {
    implicitWidth: 100
    implicitHeight: 100
    radius: 100
    IconImage {
        id: logo
        source: Appearance.profileImage
        anchors.fill: parent
        smooth: true
    }
}