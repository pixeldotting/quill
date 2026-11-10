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
        margins { top: 38; right: 0 }           // 20px внутреннего поля под тени
        implicitWidth: 420
        implicitHeight: stack.implicitHeight + 40
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-notifications"

        ColumnLayout {
            id: stack
            x: 20
            y: 20
            width: parent.width - 40
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

                    // появление: слайд справа + fade (spatial / effects)
                    opacity: 0
                    transform: Translate {
                        id: slide
                        x: 40
                        Behavior on x { SpatialAnim { speed: "default" } }
                    }
                    Component.onCompleted: { opacity = 1; slide.x = 0 }
                    Behavior on opacity { EffectsNumber {} }

                    Shadow { level: 2 }
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
                                filled: true
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
                                    role: "titleMedium"
                                    text: card.modelData.summary
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
                                font.pixelSize: Theme.typeScale.bodyMedium.size
                                font.letterSpacing: Theme.typeScale.bodyMedium.track
                                color: card.critical ? Theme.onErrorContainer : Theme.onSurfaceVariant
                            }

                            RowLayout {
                                Layout.topMargin: 6
                                visible: card.modelData.actions.length > 0
                                spacing: 6
                                Repeater {
                                    model: card.modelData.actions
                                    Rectangle {
                                        id: actionBtn
                                        required property var modelData
                                        implicitWidth: actionLabel.implicitWidth + 32
                                        implicitHeight: 36
                                        radius: aMa.pressed ? Theme.radiusSm : height / 2
                                        color: Theme.secondaryContainer
                                        Behavior on radius { SpatialAnim {} }
                                        Rectangle {
                                            anchors.fill: parent
                                            radius: parent.radius
                                            color: Theme.onSecondaryContainer
                                            opacity: aMa.pressed ? Theme.statePress : aMa.containsMouse ? Theme.stateHover : 0
                                        }
                                        Label {
                                            id: actionLabel
                                            anchors.centerIn: parent
                                            role: "labelLarge"
                                            text: actionBtn.modelData.text
                                            color: Theme.onSecondaryContainer
                                        }
                                        MouseArea {
                                            id: aMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: actionBtn.modelData.invoke()
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
