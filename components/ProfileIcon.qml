import Quickshell.Widgets
import qs.modules
import Quickshell

ClippingRectangle {
    id: root
    implicitWidth: 100
    implicitHeight: implicitWidth
    property string username: Quickshell.env("USER")
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
        source: root.username !== "" ? "file:///var/lib/whisker/avatars/" + root.username : ""
        anchors.fill: parent
        smooth: true
    }
}
