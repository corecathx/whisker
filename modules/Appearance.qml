pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.preferences

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
    property string wallpaper: !!Preferences.theme.wallpaper && Preferences.theme.wallpaper !== "" ? "file://" + Preferences.theme.wallpaper : ""

    /**
     * URI to the user’s profile image, typically located at ~/.face.
     * @values string (file:// URI)
     */
    property string profileImage: "file://" + "/var/lib/whisker/avatars/" + Quickshell.env("USER")
    property int _profileImageChanges: 0
    function refreshProfileImage() {
        root._profileImageChanges++;
    }
    /**
     * Path to the whisker (logo) icon.
     * @values string (file path)
     */
    property string whiskerIcon: "file://"+Utils.getPath("logo.png")

    property real barSize: 44

    property M3Rounding rounding: M3Rounding {}
    property M3Palette colors: M3Palette {}
    property AnimationStruct animation: AnimationStruct {}

    property string lastData: ''

    function getScheme(scheme: string): var {
        if (root.lastData === '')
            return null;

        let schemeData = JSON.parse(root.lastData);
        const selectedScheme = schemeData[scheme];

        if (!selectedScheme)
            return null;

        const mode = getMode(schemeData)

        var outputColors = {};

        for (const [name, colorModes] of Object.entries(selectedScheme)) {
            if (colorModes[mode])
                outputColors[name] = colorModes[mode];
        }

        return outputColors;
    }

    function reloadScheme(data: string): void {
        if (data !== '' && root.lastData !== data)
            root.lastData = data;
        if (root.lastData === '')
            return
        let schemeData;
        try {
            schemeData = JSON.parse(root.lastData);
        } catch (e) {
            console.error("Failed to parse JSON:", e);
            return;
        }

        const selectedScheme = schemeData[Preferences.theme.scheme];
        if (!selectedScheme) {
            return;
        }

        const mode = getMode(schemeData)

        for (const [name, colorModes] of Object.entries(selectedScheme)) {
            const propName = `m3${name}`;
            if (root.colors.hasOwnProperty(propName)) {
                if (colorModes[mode]) {
                    root.colors[propName] = colorModes[mode];
                }
            }
        }
    }

    function getMode(schemeData) {
        if (Preferences.theme.smart)
            return schemeData.mode || "dark";

        return Preferences.theme.dark ? "dark" : "light";
    }

    FileView {
        id: schemesWatcher
        path: Utils.getUserLocalRelativePath('schemes.json')
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.reloadScheme(text())
    }
    component M3Rounding: QtObject {
        property real scale: 1.0

        property real extraSmall: 4 * scale
        property real small: 8 * scale
        property real medium: 12 * scale
        property real large: 16 * scale
        property real extraLarge: 28 * scale
    }

    component AnimationStruct: QtObject {
        property real multiplier: 1

        property real fastest: 150 * multiplier
        property real fast: 300 * multiplier
        property real medium: 500 * multiplier
        property real slow: 1000 * multiplier

        property var easing: Easing.OutCubic
        property var easingExpressive: Easing.OutBack
    }
    component M3Palette: QtObject {
        property color m3background: "#121318"
        property color m3error: "#ffb4ab"
        property color m3error_container: "#93000a"
        property color m3inverse_on_surface: "#2f3036"
        property color m3inverse_primary: "#4a5c92"
        property color m3inverse_surface: "#e3e2e9"
        property color m3on_background: "#e3e2e9"
        property color m3on_error: "#690005"
        property color m3on_error_container: "#ffdad6"
        property color m3on_primary: "#192e60"
        property color m3on_primary_container: "#dbe1ff"
        property color m3on_primary_fixed: "#00184a"
        property color m3on_primary_fixed_variant: "#324578"
        property color m3on_secondary: "#2a3042"
        property color m3on_secondary_container: "#dde1f9"
        property color m3on_secondary_fixed: "#151b2c"
        property color m3on_secondary_fixed_variant: "#414659"
        property color m3on_surface: "#e3e2e9"
        property color m3on_surface_variant: "#c5c6d0"
        property color m3on_tertiary: "#422741"
        property color m3on_tertiary_container: "#ffd6f8"
        property color m3on_tertiary_fixed: "#2b122b"
        property color m3on_tertiary_fixed_variant: "#5a3d58"
        property color m3outline: "#8f909a"
        property color m3outline_variant: "#45464f"
        property color m3primary: "#b3c5ff"
        property color m3primary_container: "#324578"
        property color m3primary_fixed: "#dbe1ff"
        property color m3primary_fixed_dim: "#b3c5ff"
        property color m3scrim: "#000000"
        property color m3secondary: "#c1c6dd"
        property color m3secondary_container: "#414659"
        property color m3secondary_fixed: "#dde1f9"
        property color m3secondary_fixed_dim: "#c1c6dd"
        property color m3shadow: "#000000"
        property color m3surface: "#121318"
        property color m3surface_bright: "#38393f"
        property color m3surface_container: "#1e1f25"
        property color m3surface_container_high: "#292a2f"
        property color m3surface_container_highest: "#33343a"
        property color m3surface_container_low: "#1a1b21"
        property color m3surface_container_lowest: "#0d0e13"
        property color m3surface_dim: "#121318"
        property color m3surface_tint: "#b3c5ff"
        property color m3surface_variant: "#45464f"
        property color m3tertiary: "#e2bbdc"
        property color m3tertiary_container: "#5a3d58"
        property color m3tertiary_fixed: "#ffd6f8"
        property color m3tertiary_fixed_dim: "#e2bbdc"
    }


}
