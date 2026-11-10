import QtQuick
import QtQuick.Layouts
import qs.services

// Toggle-тайл быстрых настроек. Нажатие: пилюля → скруглённый прямоугольник (пружина). Активный: primary + filled-иконка.
Rectangle {
    id: root
    property string icon
    property string title
    property string subtitle
    property bool active: false
    signal clicked()

    Layout.fillWidth: true
    implicitHeight: 64
    radius: ma.pressed ? Theme.radiusLg : height / 2
    color: active ? Theme.primary : Theme.surfaceContainerHighest
    Behavior on radius { SpatialAnim { speed: "fast" } }
    Behavior on color { EffectsColor {} }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.active ? Theme.onPrimary : Theme.onSurface
        opacity: ma.pressed ? Theme.statePress : ma.containsMouse ? Theme.stateHover : 0
        Behavior on opacity { EffectsNumber { speed: "fast" } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 14
        spacing: 12

        Icon {
            text: root.icon
            size: 24
            filled: root.active
            color: root.active ? Theme.onPrimary : Theme.onSurfaceVariant
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Label {
                Layout.fillWidth: true
                role: "titleSmall"
                text: root.title
                color: root.active ? Theme.onPrimary : Theme.onSurface
            }
            Label {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                role: "bodySmall"
                text: root.subtitle
                color: root.active ? Theme.onPrimary : Theme.onSurfaceVariant
                opacity: 0.85
            }
        }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
