pragma Singleton
import QtQuick
import Quickshell

QtObject {
    /**
     * Panel opacity, from 0 (fully transparent) to 1 (fully opaque).
     * @values real: 0.0 - 1.0
     */
    property real panel_opacity: 0.7

    /**
     * The color of the panel, based on background and opacity.
     * @values color
     */
    property color panel_color: Colors.opacify(Colors.background, panel_opacity)

    /**
     * URI to the current wallpaper.
     * @values string (file:// URI)
     */
    property string wallpaper: "file://" + Colors.wallpaper

    /**
     * URI to the user’s profile image, typically located at ~/.face.
     * @values string (file:// URI)
     */
    property string profileImage: "file://" + "/home/" + Quickshell.env("USER") + "/.face"

    /**
     * Path to the whisker (logo) icon.
     * @values string (file path)
     */
    property string whiskerIcon: Utils.getPath("logo.png")

    /**
     * Multiplier for animation durations.
     * @values real
     */
    property real anim_multiplier: 1

    /**
     * Duration for slow animations (in milliseconds).
     * @values int
     */
    property real anim_slow: 1000 * anim_multiplier

    /**
     * Duration for medium animations (in milliseconds).
     * @values int
     */
    property real anim_medium: 500 * anim_multiplier

    /**
     * Duration for fast animations (in milliseconds).
     * @values int
     */
    property real anim_fast: 250 * anim_multiplier

    /**
     * Whether to use small bar layout.
     * @values bool: true, false
     */
    property bool smallBar: true
}
