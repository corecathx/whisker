import Quickshell.Widgets
import qs.modules

ClippingRectangle {
    id: root
    implicitWidth: 100
    implicitHeight: implicitWidth
    radius: 100
    color: Appearance.colors.m3surface_container
    MaterialIcon {
        icon: "person"
        anchors.centerIn: parent
        font.pixelSize: root.implicitWidth * 0.6
        color: Appearance.colors.m3on_surface_variant
    }
    IconImage {
        id: logo
        source: Appearance.profileImage
        anchors.fill: parent
        smooth: true
    }
}
