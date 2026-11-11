import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Power menu. Mod+Shift+E. Big squircle buttons: the shape springs on hover/press.
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
                    { icon: "bedtime",            label: "Sleep",        danger: false, cmd: ["systemctl", "suspend"] },
                    { icon: "logout",             label: "Log out",      danger: false, cmd: ["niri", "msg", "action", "quit", "--skip-confirmation"] },
                    { icon: "restart_alt",        label: "Restart",       danger: false, cmd: ["systemctl", "reboot"] },
                    { icon: "power_settings_new", label: "Shut down",    danger: true,  cmd: ["systemctl", "poweroff"] }
                ]

                ColumnLayout {
                    id: item
                    required property var modelData
                    spacing: 10

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 96
                        implicitHeight: 96
                        // shape: idle — 28, hover — almost a circle, press — 16
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
