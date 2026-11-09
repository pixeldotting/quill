import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Центр управления: сеть, тема, DND, обои, громкость, яркость, медиа. Mod+C
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
        radius: Theme.radiusXl
        color: Theme.surfaceContainer
        opacity: win.progress
        scale: 0.94 + 0.06 * win.progress
        transformOrigin: Item.TopRight

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 20 }
            spacing: 12

            // Тайлы
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 8
                rowSpacing: 8

                Tile {
                    icon: System.netIcon
                    title: "Сеть"
                    subtitle: System.netConnected ? System.netName : "Не подключено"
                    active: System.netConnected
                }
                Tile {
                    icon: System.dark ? "dark_mode" : "light_mode"
                    title: "Тема"
                    subtitle: System.dark ? "Тёмная" : "Светлая"
                    active: true
                    onClicked: System.setDark(!System.dark)
                }
                Tile {
                    icon: UiState.dnd ? "notifications_off" : "notifications"
                    title: "Не беспокоить"
                    subtitle: UiState.dnd ? "Включено" : "Выключено"
                    active: UiState.dnd
                    onClicked: UiState.dnd = !UiState.dnd
                }
                Tile {
                    icon: "wallpaper"
                    title: "Обои"
                    subtitle: "Сменить и перекрасить"
                    onClicked: UiState.toggle("wallpapers")
                }
            }

            // Громкость и яркость
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

            // Медиаплеер
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
                            text: System.player ? (System.player.trackTitle || "Без названия") : ""
                            font.weight: Font.Medium
                        }
                        Label {
                            Layout.fillWidth: true
                            text: System.player ? System.player.trackArtist : ""
                            font.pixelSize: 12
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
