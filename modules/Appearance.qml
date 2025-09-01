pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id:root
    /**
     * Panel opacity, from 0 (fully transparent) to 1 (fully opaque).
     * @values real: 0.0 - 1.0
     */
    property real panel_opacity: 1

    /**
     * The color of the panel, based on background and opacity.
     * @values color
     */
    property color panel_color: Colors.opacify(Appearance.colors.m3background, panel_opacity)

    /**
     * URI to the current wallpaper.
     * @values string (file:// URI)
     */
    property string wallpaper: !!Colors.wallpaper && Colors.wallpaper !== "" ? "file://" + Colors.wallpaper : ""

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

    property M3Palette colors: M3Palette {}
    function load(data: string): void {
        const scheme = JSON.parse(data);

        for (const [name, color] of Object.entries(scheme.colors.dark)) {
            const propName = `m3${name}`;
            if (root.colors.hasOwnProperty(propName))
                root.colors[propName] = color;
        }
    }
    FileView {
        path: Utils.getPath('colors.json')
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.load(text())
    }
    component M3Palette: QtObject {
        property color m3background: "#111318"
        property color m3error: "#ffb4ab"
        property color m3error_container: "#93000a"
        property color m3inverse_on_surface: "#2f3036"
        property color m3inverse_primary: "#445e91"
        property color m3inverse_surface: "#e2e2e9"
        property color m3on_background: "#e2e2e9"
        property color m3on_error: "#690005"
        property color m3on_error_container: "#ffdad6"
        property color m3on_primary: "#102f60"
        property color m3on_primary_container: "#d8e2ff"
        property color m3on_primary_fixed: "#001a41"
        property color m3on_primary_fixed_variant: "#2b4678"
        property color m3on_secondary: "#293041"
        property color m3on_secondary_container: "#dbe2f9"
        property color m3on_secondary_fixed: "#141b2c"
        property color m3on_secondary_fixed_variant: "#3f4759"
        property color m3on_surface: "#e2e2e9"
        property color m3on_surface_variant: "#c4c6d0"
        property color m3on_tertiary: "#402843"
        property color m3on_tertiary_container: "#fbd7fc"
        property color m3on_tertiary_fixed: "#29132d"
        property color m3on_tertiary_fixed_variant: "#583e5b"
        property color m3outline: "#8e9099"
        property color m3outline_variant: "#44474f"
        property color m3primary: "#adc6ff"
        property color m3primary_container: "#2b4678"
        property color m3primary_fixed: "#d8e2ff"
        property color m3primary_fixed_dim: "#adc6ff"
        property color m3scrim: "#000000"
        property color m3secondary: "#bfc6dc"
        property color m3secondary_container: "#3f4759"
        property color m3secondary_fixed: "#dbe2f9"
        property color m3secondary_fixed_dim: "#bfc6dc"
        property color m3shadow: "#000000"
        property color m3surface: "#111318"
        property color m3surface_bright: "#37393e"
        property color m3surface_container: "#1e1f25"
        property color m3surface_container_high: "#282a2f"
        property color m3surface_container_highest: "#33353a"
        property color m3surface_container_low: "#1a1b20"
        property color m3surface_container_lowest: "#0c0e13"
        property color m3surface_dim: "#111318"
        property color m3surface_tint: "#adc6ff"
        property color m3surface_variant: "#44474f"
        property color m3tertiary: "#debcdf"
        property color m3tertiary_container: "#583e5b"
        property color m3tertiary_fixed: "#fbd7fc"
        property color m3tertiary_fixed_dim: "#debcdf"
    }


}
