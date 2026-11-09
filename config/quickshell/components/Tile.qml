import QtQuick
import QtQuick.Layouts
import qs.services

// Тайл быстрых настроек. При нажатии форма «морфится» из пилюли в скруглённый прямоугольник (M3 Expressive)
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
    Behavior on radius { NumberAnimation { duration: 200; easing.type: Easing.BezierSpline; easing.bezierCurve: Theme.emphasized } }
    Behavior on color { ColorAnimation { duration: Theme.durShort } }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.active ? Theme.onPrimary : Theme.onSurface
        opacity: ma.containsMouse ? 0.08 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 18
        anchors.rightMargin: 14
        spacing: 12

        Icon {
            text: root.icon
            size: 24
            color: root.active ? Theme.onPrimary : Theme.onSurfaceVariant
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Label {
                Layout.fillWidth: true
                text: root.title
                font.weight: Font.Medium
                color: root.active ? Theme.onPrimary : Theme.onSurface
            }
            Label {
                Layout.fillWidth: true
                visible: root.subtitle !== ""
                text: root.subtitle
                font.pixelSize: 12
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
