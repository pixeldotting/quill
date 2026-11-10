import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.components

// Оформление: стиль палитры (Android: Tonal Spot / Expressive / Fruit Salad / Rainbow …), контраст
// и выбор обоев из ~/Pictures/Wallpapers. Клик → перекрашивается вся система. Mod+W
Overlay {
    id: win
    open: UiState.wallpapersOpen
    onDismissed: UiState.wallpapersOpen = false

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 800)
        height: Math.min(parent.height - 100, 620)
        radius: Theme.radiusXlInc
        color: Theme.surfaceContainer
        opacity: win.progress
        scale: 0.9 + 0.1 * win.pop

        Shadow { level: 4 }
        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 24
            spacing: 14

            RowLayout {
                Layout.fillWidth: true
                Icon { text: "palette"; size: 28; filled: true; color: Theme.primary }
                Label {
                    Layout.fillWidth: true
                    role: "headlineSmall"
                    text: "Оформление"
                }
                IconButton { icon: "close"; onClicked: win.dismissed() }
            }

            // ---- стиль палитры ----
            Label { role: "labelLarge"; text: "Стиль палитры"; color: Theme.onSurfaceVariant }
            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: [
                        { id: "scheme-tonal-spot",  name: "Tonal spot" },
                        { id: "scheme-expressive",  name: "Expressive" },
                        { id: "scheme-fruit-salad", name: "Fruit salad" },
                        { id: "scheme-rainbow",     name: "Rainbow" },
                        { id: "scheme-fidelity",    name: "Fidelity" },
                        { id: "scheme-neutral",     name: "Neutral" },
                        { id: "scheme-monochrome",  name: "Monochrome" }
                    ]
                    Chip {
                        required property var modelData
                        text: modelData.name
                        selected: System.scheme === modelData.id
                        onClicked: System.setScheme(modelData.id)
                    }
                }
            }

            // ---- контраст ----
            Label { role: "labelLarge"; text: "Контраст"; color: Theme.onSurfaceVariant }
            Flow {
                Layout.fillWidth: true
                spacing: 8
                Repeater {
                    model: [
                        { v: 0.0, name: "Стандартный" },
                        { v: 0.5, name: "Средний" },
                        { v: 1.0, name: "Высокий" }
                    ]
                    Chip {
                        required property var modelData
                        text: modelData.name
                        selected: Math.abs(System.contrast - modelData.v) < 0.01
                        onClicked: System.setContrast(modelData.v)
                    }
                }
            }

            // ---- обои ----
            Label { role: "labelLarge"; text: "Обои"; color: Theme.onSurfaceVariant }
            Label {
                Layout.fillWidth: true
                visible: grid.count === 0
                role: "bodyMedium"
                text: "Положи картинки в ~/Pictures/Wallpapers"
                color: Theme.onSurfaceVariant
            }

            GridView {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                cellWidth: width / 3
                cellHeight: cellWidth * 0.62
                boundsBehavior: Flickable.StopAtBounds

                model: FolderListModel {
                    folder: "file://" + WallpaperState.dir
                    nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp", "*.JPG", "*.PNG"]
                    showDirs: false
                    sortField: FolderListModel.Name
                }

                delegate: Item {
                    id: cell
                    required property string filePath
                    required property url fileUrl
                    width: grid.cellWidth
                    height: grid.cellHeight
                    readonly property bool current: filePath === WallpaperState.path

                    ClippingRectangle {
                        anchors.fill: parent
                        anchors.margins: 5
                        // текущие обои — «таблетка»-скругление, hover — мягче
                        radius: cell.current ? Theme.radiusXl : (ma.containsMouse ? Theme.radiusLgInc : Theme.radiusLg)
                        color: Theme.surfaceContainerHighest
                        border.width: cell.current ? 3 : 0
                        border.color: Theme.primary
                        Behavior on radius { SpatialAnim { speed: "default" } }

                        Image {
                            anchors.fill: parent
                            source: cell.fileUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 420
                            scale: ma.containsMouse ? 1.06 : 1
                            Behavior on scale { SpatialAnim { speed: "slow" } }
                        }

                        Rectangle {
                            visible: cell.current
                            anchors { right: parent.right; top: parent.top; margins: 10 }
                            width: 28; height: 28; radius: 14
                            color: Theme.primary
                            Icon { anchors.centerIn: parent; text: "check"; size: 18; color: Theme.onPrimary }
                        }

                        MouseArea {
                            id: ma
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Quickshell.execDetached([System.themeScript, "set", cell.filePath])
                        }
                    }
                }
            }
        }
    }
}
