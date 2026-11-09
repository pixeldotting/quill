import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services
import qs.components

// Лаунчер приложений (вместо rofi/wofi/fuzzel). Mod+Space
Overlay {
    id: win
    open: UiState.launcherOpen
    onDismissed: UiState.launcherOpen = false
    onOpenChanged: {
        if (open) {
            input.text = ""
            list.currentIndex = 0
            Qt.callLater(() => input.forceActiveFocus())
        }
    }

    function results(q) {
        const apps = DesktopEntries.applications.values.filter(a => !a.noDisplay)
        q = q.trim().toLowerCase()
        if (q === "")
            return apps.slice().sort((a, b) => a.name.localeCompare(b.name)).slice(0, 7)

        const scored = []
        for (const a of apps) {
            const n = a.name.toLowerCase()
            let s = 0
            if (n.startsWith(q)) s = 3
            else if (n.includes(q)) s = 2
            else if ((a.genericName ?? "").toLowerCase().includes(q)
                  || (a.comment ?? "").toLowerCase().includes(q)) s = 1
            if (s > 0) scored.push({ a: a, s: s })
        }
        scored.sort((x, y) => (y.s - x.s) || x.a.name.localeCompare(y.a.name))
        return scored.slice(0, 7).map(x => x.a)
    }

    function launch(entry) {
        if (!entry) return
        entry.execute()
        UiState.launcherOpen = false
    }

    Rectangle {
        id: card
        width: 640
        height: col.implicitHeight + 24
        x: (parent.width - width) / 2
        y: parent.height * 0.16
        radius: Theme.radiusXl
        color: Theme.surfaceContainer
        opacity: win.progress
        scale: 0.96 + 0.04 * win.progress

        MouseArea { anchors.fill: parent }   // не пропускать клики на scrim

        ColumnLayout {
            id: col
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
            spacing: 8

            // M3 search bar
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 56
                radius: height / 2
                color: Theme.surfaceContainerHigh

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 18
                    spacing: 12
                    Icon { text: "search"; size: 24; color: Theme.onSurfaceVariant }
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 40
                        Label {
                            anchors.verticalCenter: parent.verticalCenter
                            visible: input.text === ""
                            text: "Поиск приложений"
                            font.pixelSize: 16
                            color: Theme.onSurfaceVariant
                        }
                        TextInput {
                            id: input
                            anchors.fill: parent
                            verticalAlignment: TextInput.AlignVCenter
                            font.family: Theme.fontSans
                            font.pixelSize: 16
                            color: Theme.onSurface
                            selectionColor: Theme.primary
                            selectedTextColor: Theme.onPrimary
                            clip: true
                            onTextChanged: list.currentIndex = 0
                            Keys.onPressed: e => {
                                if (e.key === Qt.Key_Down || ((e.modifiers & Qt.ControlModifier) && e.key === Qt.Key_N)) {
                                    list.currentIndex = Math.min(list.count - 1, list.currentIndex + 1)
                                    e.accepted = true
                                } else if (e.key === Qt.Key_Up || ((e.modifiers & Qt.ControlModifier) && e.key === Qt.Key_P)) {
                                    list.currentIndex = Math.max(0, list.currentIndex - 1)
                                    e.accepted = true
                                } else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) {
                                    win.launch(scriptModel.values[list.currentIndex])
                                    e.accepted = true
                                } else if (e.key === Qt.Key_Escape) {
                                    win.dismissed()
                                    e.accepted = true
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: list
                Layout.fillWidth: true
                implicitHeight: count * 56
                interactive: false
                currentIndex: 0

                model: ScriptModel {
                    id: scriptModel
                    values: win.results(input.text)
                }

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    required property int index
                    width: ListView.view.width
                    height: 56
                    radius: height / 2
                    color: ListView.isCurrentItem ? Theme.secondaryContainer : "transparent"
                    Behavior on color { ColorAnimation { duration: 100 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 14
                        anchors.rightMargin: 18
                        spacing: 14
                        Image {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            sourceSize.width: 64
                            sourceSize.height: 64
                            source: Quickshell.iconPath(row.modelData.icon, "application-x-executable")
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label {
                                Layout.fillWidth: true
                                text: row.modelData.name
                                font.pixelSize: 15
                                color: row.ListView.isCurrentItem ? Theme.onSecondaryContainer : Theme.onSurface
                            }
                            Label {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: row.modelData.comment ?? ""
                                font.pixelSize: 12
                                color: Theme.onSurfaceVariant
                            }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: list.currentIndex = row.index
                        onClicked: win.launch(row.modelData)
                    }
                }
            }
        }
    }
}
