pragma Singleton
import QtQuick
import Quickshell

// Shared overlay state. toggle("launcher" | "controlCenter" | "powerMenu" | "wallpapers")
Singleton {
    id: root

    property bool launcherOpen: false
    property bool controlCenterOpen: false
    property bool powerMenuOpen: false
    property bool wallpapersOpen: false
    property bool dnd: false

    function closeAll() {
        launcherOpen = false
        controlCenterOpen = false
        powerMenuOpen = false
        wallpapersOpen = false
    }

    function toggle(name) {
        const key = name + "Open"
        const was = root[key]
        closeAll()
        root[key] = !was
    }
}
