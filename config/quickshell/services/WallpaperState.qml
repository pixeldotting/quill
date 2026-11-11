pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Current wallpaper (the path is written by scripts/theme.sh)
Singleton {
    id: root
    property string path: ""
    readonly property string dir: Quickshell.env("HOME") + "/Pictures/Wallpapers"

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/material/wallpaper"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.path = text().trim()
    }
}
