import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.services
import qs.components

// Демон уведомлений (вместо mako/dunst/swaync)
Scope {
    id: root

    NotificationServer {
        id: server
        actionsSupported: true
        bodyMarkupSupported: true
        imageSupported: true
        keepOnReload: false

        onNotification: n => {
            // «Не беспокоить» пропускает только критические
            if (!UiState.dnd || n.urgency === NotificationUrgency.Critical)
                n.tracked = true
        }
    }

    PanelWindow {
        visible: server.trackedNotifications.values.length > 0
        anchors { top: true; right: true }
        margins { top: 58; right: 12 }
        implicitWidth: 380
        implicitHeight: stack.implicitHeight
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-notifications"

        ColumnLayout {
            id: stack
            width: parent.width
            spacing: 8

            Repeater {
                model: server.trackedNotifications

                Rectangle {
                    id: card
                    required property var modelData
                    readonly property bool critical: modelData.urgency === NotificationUrgency.Critical

                    Layout.fillWidth: true
                    implicitHeight: content.implicitHeight + 28
                    radius: Theme.radiusXl
                    color: critical ? Theme.errorContainer : Theme.surfaceContainerHigh

                    HoverHandler { id: hover }

                    Timer {
                        interval: card.modelData.expireTimeout > 0 ? card.modelData.expireTimeout * 1000 : 6000
                        running: !card.critical && !hover.hovered
                        onTriggered: card.modelData.expire()
                    }

                    RowLayout {
                        id: content
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                        spacing: 12

                        // иконка приложения / картинка
                        Rectangle {
                            Layout.alignment: Qt.AlignTop
                            implicitWidth: 44
                            implicitHeight: 44
                            radius: 22
                            color: card.critical ? Theme.error : Theme.primaryContainer
                            Image {
                                id: img
                                anchors.centerIn: parent
                                width: 28
                                height: 28
                                sourceSize.width: 56
                                sourceSize.height: 56
                                fillMode: Image.PreserveAspectFit
                                source: card.modelData.image !== "" ? card.modelData.image
                                      : card.modelData.appIcon !== "" ? Quickshell.iconPath(card.modelData.appIcon, true)
                                      : ""
                                visible: status === Image.Ready
                            }
                            Icon {
                                anchors.centerIn: parent
                                visible: !img.visible
                                text: card.critical ? "priority_high" : "notifications"
                                size: 24
                                color: card.critical ? Theme.onError : Theme.onPrimaryContainer
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            RowLayout {
                                Layout.fillWidth: true
                                Label {
                                    Layout.fillWidth: true
                                    text: card.modelData.summary
                                    font.weight: Font.Medium
                                    font.pixelSize: 15
                                    color: card.critical ? Theme.onErrorContainer : Theme.onSurface
                                }
                                IconButton {
                                    icon: "close"
                                    iconSize: 18
                                    implicitWidth: 28
                                    implicitHeight: 28
                                    tone: card.critical ? Theme.onErrorContainer : Theme.onSurfaceVariant
                                    onClicked: card.modelData.dismiss()
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: card.modelData.body
                                textFormat: Text.StyledText
                                wrapMode: Text.Wrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                font.family: Theme.fontSans
                                font.pixelSize: 13
                                color: card.critical ? Theme.onErrorContainer : Theme.onSurfaceVariant
                            }

                            RowLayout {
                                Layout.topMargin: 6
                                visible: card.modelData.actions.length > 0
                                spacing: 6
                                Repeater {
                                    model: card.modelData.actions
                                    Rectangle {
                                        required property var modelData
                                        implicitWidth: actionLabel.implicitWidth + 28
                                        implicitHeight: 32
                                        radius: 16
                                        color: Theme.secondaryContainer
                                        Label {
                                            id: actionLabel
                                            anchors.centerIn: parent
                                            text: parent.modelData.text
                                            font.pixelSize: 13
                                            color: Theme.onSecondaryContainer
                                        }
                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: parent.modelData.invoke()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
