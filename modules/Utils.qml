pragma Singleton
import QtQuick
import Quickshell

QtObject {
    function getPath(key) {
        return Quickshell.shellDir + '/' + key
    }

    function getConfigRelativePath(key) {
        return Quickshell.env("HOME") + "/.config/whisker/" + key
    }

    function getUserLocalRelativePath(key) {
        return Quickshell.env("HOME") + "/.local/share/whisker/" + key
    }

    function truncateText(text: string, maxLength: int): string {
        if (text.length <= maxLength)
            return text;
        return text.slice(0, maxLength - 3) + "...";
    }

    function getAppIcon(name: string, fallback: string): string {
        const icon = DesktopEntries.heuristicLookup(name)?.icon;
        if (fallback !== "undefined")
            return Quickshell.iconPath(icon, fallback);
        return Quickshell.iconPath(icon);
    }

    function formatSeconds(s: int) {
        const day = Math.floor(s / 86400);
        const hr = Math.floor(s / 3600) % 60;
        const min = Math.floor(s / 60) % 60;

        let comps = [];
        if (day > 0)
            comps.push(`${day}d`);
        if (hr > 0)
            comps.push(`${hr}h`);
        if (min > 0)
            comps.push(`${min}m`);

        return comps.join(" ");
    }
    function isVideo(path) {
        if (!path) return false
        var videoExts = ["mp4", "mkv", "webm", "avi", "mov", "flv", "wmv", "m4v"]
        var ext = path.split(".").pop().toLowerCase()
        return videoExts.indexOf(ext) !== -1
    }
}
