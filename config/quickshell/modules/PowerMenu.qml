import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Меню питания. Mod+Shift+E. Кнопки — крупные «цветочные» квадраты: на hover/press форма пружинит.
Overlay {
    id: win
    open: UiState.powerMenuOpen
    onDismissed: UiState.powerMenuOpen = false

    function run(cmd) {
        UiState.powerMenuOpen = false
        Quickshell.execDetached(cmd)
    }

    Rectangle {
        anchors.centerIn: parent
        width: row.implicitWidth + 56
        height: row.implicitHeight + 56
        radius: Theme.radiusXxl
        color: Theme.surfaceContainer
        opacity: win.progress
        scale: 0.9 + 0.1 * win.pop

        Shadow { level: 4 }
        MouseArea { anchors.fill: parent }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                model: [
                    { icon: "bedtime",            label: "Сон",          danger: false, cmd: ["systemctl", "suspend"] },
                    { icon: "logout",             label: "Выйти",        danger: false, cmd: ["niri", "msg", "action", "quit", "--skip-confirmation"] },
                    { icon: "restart_alt",        label: "Перезагрузка", danger: false, cmd: ["systemctl", "reboot"] },
                    { icon: "power_settings_new", label: "Выключить",    danger: true,  cmd: ["systemctl", "poweroff"] }
                ]

                ColumnLayout {
                    id: item
                    required property var modelData
                    spacing: 10

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 96
                        implicitHeight: 96
                        // форма: покой — 28, hover — почти круг, нажатие — 16
                        radius: ma.pressed ? Theme.radiusLg : (ma.containsMouse ? 48 : Theme.radiusXl)
                        color: ma.containsMouse
                            ? (item.modelData.danger ? Theme.error : Theme.primary)
                            : (item.modelData.danger ? Theme.errorContainer : Theme.secondaryContainer)
                        Behavior on radius { SpatialAnim { speed: "default" } }
                        Behavior on color { EffectsColor {} }

                        Icon {
                            anchors.centerIn: parent
                            text: item.modelData.icon
                            size: 36
                            filled: ma.containsMouse
                            color: ma.containsMouse
                                ? (item.modelData.danger ? Theme.onError : Theme.onPrimary)
                                : (item.modelData.danger ? Theme.onErrorContainer : Theme.onSecondaryContainer)
                        }
                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: win.run(item.modelData.cmd)
                        }
                    }
                    Label {
                        Layout.alignment: Qt.AlignHCenter
                        role: "labelLarge"
                        text: item.modelData.label
                        color: Theme.onSurfaceVariant
                    }
                }
            }
        }
    }
}
