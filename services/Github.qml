pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import qs.preferences

Singleton {
    id: root
    property int contributionNumber
    property string author: Preferences.misc.githubUsername
    property bool loaded: false
    property var contributions: []

    Timer {
        id: debounceTimer
        interval: 1000
        repeat: false
        onTriggered: {
            if (root.author && root.author.length > 0) {
                root.loaded = false;
                root.contributions = [];
                root.contributionNumber = 0;
                getContributions.running = true;
            }
        }
    }

    onAuthorChanged: {
        debounceTimer.restart();
    }

    Timer {
        interval: 600000
        running: true
        repeat: true
        onTriggered: {
            if (root.author && root.author.length > 0) {
                root.loaded = false;
                root.contributions = [];
                root.contributionNumber = 0;
                getContributions.running = true;
            }
        }
    }

    Process {
        id: getContributions
        running: root.author && root.author.length > 0
        command: ["curl", `https://github-contributions-api.jogruber.de/v4/${root.author}`]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const json = JSON.parse(text);
                    const year = Time.year;
                    const oneYearAgo = new Date();
                    oneYearAgo.setDate(oneYearAgo.getDate() - 365);
                    root.contributionNumber = json.contributions.filter(c => new Date(c.date) >= oneYearAgo).reduce((sum, c) => sum + c.count, 0);
                    const allContribs = json.contributions;
                    const today = new Date();
                    const cutoff = new Date(today);
                    cutoff.setDate(cutoff.getDate() - 280);
                    const recentContribs = allContribs.filter(c => new Date(c.date) >= cutoff).sort((a, b) => new Date(a.date) - new Date(b.date));
                    root.contributions = recentContribs;
                    root.loaded = true;
                } catch (e) {
                    console.error("Failed to parse GitHub contributions:", e);
                    root.loaded = false;
                }
            }
        }
    }
}
