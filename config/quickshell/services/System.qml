pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Services.Mpris

// Audio, battery, network, brightness, media, dark/light theme
Singleton {
    id: root

    readonly property string themeScript: Quickshell.shellDir + "/scripts/theme.sh"

    // ---------- audio ----------
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property real volume: sink?.audio ? sink.audio.volume : 0
    readonly property bool muted: sink?.audio ? sink.audio.muted : false
    PwObjectTracker { objects: [root.sink] }

    function setVolume(v) {
        if (sink?.audio) {
            sink.audio.muted = false
            sink.audio.volume = Math.max(0, Math.min(1, v))
        }
    }
    function toggleMute() {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted
    }
    readonly property string volumeIcon: muted || volume <= 0 ? "volume_off"
        : volume < 0.34 ? "volume_mute"
        : volume < 0.67 ? "volume_down" : "volume_up"

    // ---------- battery ----------
    readonly property var battery: UPower.displayDevice
    readonly property bool hasBattery: battery ? battery.isLaptopBattery : false
    readonly property int batteryPercent: battery ? Math.round(battery.percentage * 100) : 0
    readonly property bool charging: battery
        ? (battery.state === UPowerDeviceState.Charging || battery.state === UPowerDeviceState.FullyCharged)
        : false
    readonly property string batteryIcon: charging ? "battery_charging_full"
        : batteryPercent >= 90 ? "battery_full"
        : batteryPercent >= 70 ? "battery_6_bar"
        : batteryPercent >= 50 ? "battery_4_bar"
        : batteryPercent >= 30 ? "battery_3_bar"
        : batteryPercent >= 15 ? "battery_2_bar" : "battery_alert"

    // ---------- network (via nmcli) ----------
    property string netKind: ""
    property string netName: ""
    readonly property bool netConnected: netKind !== ""
    readonly property string netIcon: netKind === "wifi" ? "wifi"
        : netKind === "ethernet" ? "lan" : "wifi_off"

    Process {
        id: netProc
        command: ["nmcli", "-t", "-f", "TYPE,STATE,CONNECTION", "device", "status"]
        stdout: StdioCollector {
            onStreamFinished: {
                let kind = "", name = ""
                for (const l of text.trim().split("\n")) {
                    const p = l.split(":")
                    if (p.length >= 3 && p[1] === "connected" && (p[0] === "wifi" || p[0] === "ethernet")) {
                        kind = p[0]
                        name = p.slice(2).join(":").replace(/\\:/g, ":")
                        break
                    }
                }
                root.netKind = kind
                root.netName = name
            }
        }
    }
    Timer {
        interval: 8000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: netProc.running = true
    }

    // ---------- brightness (brightnessctl) ----------
    property bool hasBrightness: false
    property real brightness: 0

    function refreshBrightness() { brProc.running = true }
    function setBrightness(v) {
        brightness = Math.max(0.01, Math.min(1, v))
        Quickshell.execDetached(["brightnessctl", "-c", "backlight", "set", Math.round(brightness * 100) + "%"])
    }

    Process {
        id: brProc
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",")
                if (f.length >= 5) {
                    root.hasBrightness = true
                    root.brightness = parseInt(f[3]) / 100
                } else {
                    root.hasBrightness = false
                }
            }
        }
    }
    Connections {
        target: UiState
        function onControlCenterOpenChanged() { if (UiState.controlCenterOpen) root.refreshBrightness() }
    }
    Component.onCompleted: refreshBrightness()

    // ---------- media (MPRIS) ----------
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null

    // ---------- palette style and contrast (read/written by theme.sh) ----------
    property string scheme: "scheme-tonal-spot"
    property real contrast: 0

    function setScheme(s) {
        scheme = s
        Quickshell.execDetached([themeScript, "scheme", s])
    }
    function setContrast(v) {
        contrast = v
        Quickshell.execDetached([themeScript, "contrast", String(v)])
    }

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/material/scheme"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.scheme = text().trim() || "scheme-tonal-spot"
    }
    FileView {
        path: Quickshell.env("HOME") + "/.local/state/material/contrast"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.contrast = parseFloat(text().trim()) || 0
    }

    // ---------- dark / light theme ----------
    property bool dark: true

    function setDark(v) {
        dark = v
        Quickshell.execDetached([themeScript, "mode", v ? "dark" : "light"])
    }

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/material/mode"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.dark = text().trim() !== "light"
    }
}
