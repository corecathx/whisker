import Quickshell.Widgets
import qs.modules
import Quickshell
import QtQuick

ClippingRectangle {
    id: root
    implicitWidth: 100
    implicitHeight: implicitWidth
    property string username: ""
    radius: 100
    color: Appearance.colors.m3surface_container
    MaterialIcon {
        icon: "person"
        anchors.centerIn: parent
        font.pixelSize: root.implicitWidth * 0.6
        color: Appearance.colors.m3on_surface_variant
    }
    Image {
        id: logo
        source: {
            const basePath = root.username !== ""
                ? "file:///var/lib/whisker/avatars/" + root.username
                : Appearance.profileImage;
            return basePath + "?" + Appearance._profileImageChanges;
        }
        anchors.fill: parent
        fillMode: Image.PreserveAspectCrop
        smooth: true
        cache: false
    }
}
