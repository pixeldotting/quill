import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Меню питания. Mod+Shift+E
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
        width: row.implicitWidth + 48
        height: row.implicitHeight + 48
        radius: Theme.radiusXl + 8
        color: Theme.surfaceContainer
        opacity: win.progress
        scale: 0.94 + 0.06 * win.progress

        MouseArea { anchors.fill: parent }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 14

            Repeater {
                model: [
                    { icon: "bedtime",            label: "Сон",           danger: false, cmd: ["systemctl", "suspend"] },
                    { icon: "logout",             label: "Выйти",         danger: false, cmd: ["niri", "msg", "action", "quit", "--skip-confirmation"] },
                    { icon: "restart_alt",        label: "Перезагрузка",  danger: false, cmd: ["systemctl", "reboot"] },
                    { icon: "power_settings_new", label: "Выключить",     danger: true,  cmd: ["systemctl", "poweroff"] }
                ]

                ColumnLayout {
                    id: item
                    required property var modelData
                    spacing: 8

                    Rectangle {
                        Layout.alignment: Qt.AlignHCenter
                        implicitWidth: 96
                        implicitHeight: 96
                        radius: ma.pressed ? 20 : (ma.containsMouse ? 32 : 28)
                        color: ma.containsMouse
                            ? (item.modelData.danger ? Theme.error : Theme.primary)
                            : (item.modelData.danger ? Theme.errorContainer : Theme.secondaryContainer)
                        Behavior on radius { NumberAnimation { duration: 220; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.emphasized } }
                        Behavior on color { ColorAnimation { duration: Theme.durShort } }

                        Icon {
                            anchors.centerIn: parent
                            text: item.modelData.icon
                            size: 36
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
                        text: item.modelData.label
                        font.pixelSize: 13
                        color: Theme.onSurfaceVariant
                    }
                }
            }
        }
    }
}
