import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Control center: network, theme, DND, wallpapers, volume, brightness, media. Mod+C
Overlay {
    id: win
    open: UiState.controlCenterOpen
    dim: false
    onDismissed: UiState.controlCenterOpen = false

    Rectangle {
        width: 400
        height: col.implicitHeight + 40
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 56
        anchors.rightMargin: 12
        radius: Theme.radiusXlInc
        color: Theme.surfaceContainer
        opacity: win.progress
        scale: 0.9 + 0.1 * win.pop
        transformOrigin: Item.TopRight

        Shadow { level: 3 }
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20 }
            spacing: 12

            // Tiles
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                Tile {
                    icon: System.netIcon
                    title: "Network"
                    subtitle: System.netConnected ? System.netName : "Not connected"
                    active: System.netConnected
                }
                Tile {
                    icon: System.dark ? "dark_mode" : "light_mode"
                    title: "Theme"
                    subtitle: System.dark ? "Dark" : "Light"
                    active: true
                    onClicked: System.setDark(!System.dark)
                }
                Tile {
                    icon: UiState.dnd ? "notifications_off" : "notifications"
                    title: "Do not disturb"
                    subtitle: UiState.dnd ? "On" : "Off"
                    active: UiState.dnd
                    onClicked: UiState.dnd = !UiState.dnd
                }
                Tile {
                    icon: "palette"
                    title: "Style"
                    subtitle: "Wallpaper & palette"
                    onClicked: UiState.toggle("wallpapers")
                }
            }

            // Volume and brightness
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                ValueSlider {
                    Layout.fillWidth: true
                    icon: System.volumeIcon
                    value: System.muted ? 0 : System.volume
                    onMoved: v => System.setVolume(v)
                }
                IconButton {
                    icon: System.muted ? "volume_up" : "volume_off"
                    onClicked: System.toggleMute()
                }
            }
            ValueSlider {
                Layout.fillWidth: true
                visible: System.hasBrightness
                icon: "brightness_6"
                value: System.brightness
                onMoved: v => System.setBrightness(v)
            }

            // Media player
            Rectangle {
                Layout.fillWidth: true
                visible: System.player !== null
                implicitHeight: 76
                radius: Theme.radiusXl
                color: Theme.surfaceContainerHighest

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 12
                    spacing: 4

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0
                        Label {
                            Layout.fillWidth: true
                            role: "titleMedium"
                            text: System.player ? (System.player.trackTitle || "Untitled") : ""
                        }
                        Label {
                            Layout.fillWidth: true
                            role: "bodyMedium"
                            text: System.player ? System.player.trackArtist : ""
                            color: Theme.onSurfaceVariant
                        }
                    }
                    IconButton {
                        icon: "skip_previous"
                        onClicked: System.player?.previous()
                    }
                    IconButton {
                        icon: System.player?.isPlaying ? "pause" : "play_arrow"
                        iconSize: 26
                        toggled: false
                        tone: Theme.onPrimary
                        fill: Theme.primary
                        implicitWidth: 48
                        implicitHeight: 48
                        onClicked: System.player?.togglePlaying()
                    }
                    IconButton {
                        icon: "skip_next"
                        onClicked: System.player?.next()
                    }
                }
            }
        }
    }
}
