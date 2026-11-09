import QtQuick
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Widgets
import qs.services
import qs.components

// Выбор обоев из ~/Pictures/Wallpapers: клик → смена обоев и перекраска всей системы (matugen). Mod+W
Overlay {
    id: win
    open: UiState.wallpapersOpen
    onDismissed: UiState.wallpapersOpen = false

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - 80, 780)
        height: Math.min(parent.height - 120, 540)
        radius: Theme.radiusXl
        color: Theme.surfaceContainer
        opacity: win.progress
        scale: 0.96 + 0.04 * win.progress

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            RowLayout {
                Layout.fillWidth: true
                Icon { text: "wallpaper"; size: 26; color: Theme.primary }
                Label {
                    Layout.fillWidth: true
                    text: "Обои"
                    font.pixelSize: 20
                    font.weight: Font.Medium
                }
                IconButton { icon: "close"; onClicked: win.dismissed() }
            }

            Label {
                Layout.fillWidth: true
                visible: grid.count === 0
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
                        radius: 20
                        color: Theme.surfaceContainerHighest
                        border.width: cell.current ? 3 : 0
                        border.color: Theme.primary

                        Image {
                            anchors.fill: parent
                            source: cell.fileUrl
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            sourceSize.width: 420
                            scale: ma.containsMouse ? 1.05 : 1
                            Behavior on scale { NumberAnimation { duration: 200 } }
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
                            onClicked: {
                                Quickshell.execDetached([System.themeScript, "set", cell.filePath])
                            }
                        }
                    }
                }
            }
        }
    }
}
