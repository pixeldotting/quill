import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Wallpaper on the Background layer — instead of swww/swaybg/hyprpaper
Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        color: Theme.surface
        WlrLayershell.layer: WlrLayer.Background
        WlrLayershell.namespace: "qs-wallpaper"

        Image {
            anchors.fill: parent
            source: WallpaperState.path !== "" ? "file://" + WallpaperState.path : ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            sourceSize.width: modelData.width
            sourceSize.height: modelData.height
            opacity: status === Image.Ready ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 400 } }
        }
    }
}
