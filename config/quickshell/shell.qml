import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.modules
import qs.services

// Весь десктоп-шелл: обои, панель, лаунчер, уведомления, OSD, центр управления,
// меню питания, выбор обоев, простой idle (выключить мониторы).
ShellRoot {
    Wallpaper {}
    Bar {}
    Launcher {}
    ControlCenter {}
    PowerMenu {}
    WallpaperPicker {}
    Notifications {}
    Osd {}

    // Выключать экраны после 10 минут простоя (просыпаются от любого ввода)
    IdleMonitor {
        timeout: 600
        onIsIdleChanged: if (isIdle) Quickshell.execDetached(["niri", "msg", "action", "power-off-monitors"])
    }

    // qs ipc call <target> <function>
    IpcHandler {
        target: "launcher"
        function toggle(): void { UiState.toggle("launcher") }
    }
    IpcHandler {
        target: "control"
        function toggle(): void { UiState.toggle("controlCenter") }
    }
    IpcHandler {
        target: "power"
        function toggle(): void { UiState.toggle("powerMenu") }
    }
    IpcHandler {
        target: "wallpapers"
        function toggle(): void { UiState.toggle("wallpapers") }
    }
    IpcHandler {
        target: "media"
        function playPause(): void { System.player?.togglePlaying() }
        function next(): void { System.player?.next() }
        function previous(): void { System.player?.previous() }
    }
}
