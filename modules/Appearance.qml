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
    property string profileImage: "file://" + "/home/" + Quickshell.env("USER") + "/.face"

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

    function getScheme(scheme: string) {
        if (root.lastData === '')
            return null;

        let schemeData = JSON.parse(root.lastData);
        const selectedScheme = schemeData[scheme];
        const mode = Preferences.theme.dark ? "dark" : "light";
        const colors = selectedScheme[mode];

        var outputColors = {};
        for (const [name, colorModes] of Object.entries(selectedScheme)) {
            if (colorModes[mode]) {
                outputColors[name] = colorModes[mode];
            }
        }

        return outputColors
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

        const mode = Preferences.theme.dark ? "dark" : "light";

        for (const [name, colorModes] of Object.entries(selectedScheme)) {
            const propName = `m3${name}`;
            if (root.colors.hasOwnProperty(propName)) {
                if (colorModes[mode]) {
                    root.colors[propName] = colorModes[mode];
                }
            }
        }
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

        property real fast: 250 * multiplier
        property real medium: 500 * multiplier
        property real slow: 1000 * multiplier

        property var easing: Easing.OutExpo
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
