import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import qs.services
import qs.components

// Top bar: three "islands" (left / center / right) on a transparent background
Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar
        required property var modelData
        screen: modelData

        anchors { top: true; left: true; right: true }
        margins { top: 8; left: 12; right: 12 }
        implicitHeight: 40
        color: "transparent"
        WlrLayershell.namespace: "qs-bar"

        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }

        // ================= left =================
        RowLayout {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Pill {
                IconButton {
                    icon: "apps"
                    iconSize: 20
                    implicitWidth: 32
                    implicitHeight: 32
                    tone: Theme.primary
                    onClicked: UiState.toggle("launcher")
                }

                // Workspaces: an indicator like the M3 Navigation bar — the active one stretches into a primary pill
                RowLayout {
                    spacing: 6
                    Repeater {
                        model: Niri.forOutput(bar.modelData.name)
                        Rectangle {
                            required property var modelData
                            Layout.alignment: Qt.AlignVCenter
                            implicitWidth: modelData.is_active ? 28 : 10
                            implicitHeight: 10
                            radius: 5
                            color: modelData.is_active ? Theme.primary
                                 : modelData.active_window_id != null ? Theme.onSurfaceVariant
                                 : Theme.outlineVariant
                            Behavior on implicitWidth { SpatialAnim { speed: "default" } }
                            Behavior on color { EffectsColor {} }
                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -5
                                cursorShape: Qt.PointingHandCursor
                                onClicked: Niri.focusWorkspace(modelData.idx)
                            }
                        }
                    }
                }
            }

            Pill {
                visible: Niri.windowTitle !== ""
                padding: 14
                Label {
                    Layout.maximumWidth: 320
                    role: "labelLarge"
                    text: Niri.windowTitle
                    color: Theme.onSurfaceVariant
                }
            }
        }

        // ================= center =================
        Pill {
            anchors.centerIn: parent
            padding: 18
            spacing: 10
            Label {
                role: "titleMedium"
                emphasized: true
                text: Qt.formatDateTime(clock.date, "HH:mm")
            }
            Label {
                role: "labelLarge"
                text: Qt.formatDateTime(clock.date, "ddd, d MMM")
                color: Theme.onSurfaceVariant
            }
        }

        // ================= right =================
        RowLayout {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            // Tray
            Pill {
                visible: SystemTray.items.values.length > 0
                Repeater {
                    model: SystemTray.items
                    Item {
                        id: trayItem
                        required property var modelData
                        implicitWidth: 28
                        implicitHeight: 28

                        Image {
                            anchors.centerIn: parent
                            width: 18
                            height: 18
                            sourceSize.width: 36
                            sourceSize.height: 36
                            source: trayItem.modelData.icon
                        }

                        QsMenuAnchor {
                            id: menu
                            menu: trayItem.modelData.menu
                            anchor.window: bar
                        }

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            cursorShape: Qt.PointingHandCursor
                            onClicked: mouse => {
                                if (mouse.button === Qt.LeftButton && !trayItem.modelData.onlyMenu) {
                                    trayItem.modelData.activate()
                                } else if (trayItem.modelData.hasMenu) {
                                    const p = trayItem.mapToItem(null, 0, 0)
                                    menu.anchor.rect = Qt.rect(p.x, bar.height + 4, trayItem.width, 1)
                                    menu.open()
                                }
                            }
                        }
                    }
                }
            }

            // Status: network, sound, battery → control center
            Pill {
                clickable: true
                padding: 14
                spacing: 10
                onClicked: UiState.toggle("controlCenter")

                Icon { text: System.netIcon; size: 20; color: Theme.onSurface }
                Icon { text: UiState.dnd ? "notifications_off" : System.volumeIcon; size: 20; color: Theme.onSurface }
                RowLayout {
                    visible: System.hasBattery
                    spacing: 2
                    Icon {
                        text: System.batteryIcon
                        size: 20
                        color: System.batteryPercent < 15 && !System.charging ? Theme.error : Theme.onSurface
                    }
                    Label {
                        role: "labelMedium"
                        text: System.batteryPercent + "%"
                    }
                }
            }

            IconButton {
                icon: "power_settings_new"
                tone: Theme.onErrorContainer
                fill: Theme.errorContainer
                onClicked: UiState.toggle("powerMenu")
            }
        }
    }
}
