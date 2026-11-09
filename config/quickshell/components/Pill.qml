import QtQuick
import QtQuick.Layouts
import qs.services

// «Островок» панели: скруглённая поверхность surface-container с содержимым в ряд
Rectangle {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property real padding: 8
    property bool clickable: false
    signal clicked()

    implicitHeight: 40
    implicitWidth: row.implicitWidth + padding * 2
    radius: height / 2
    color: Theme.surfaceContainer

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Theme.onSurface
        opacity: root.clickable && ma.containsMouse ? 0.08 : 0
        Behavior on opacity { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        enabled: root.clickable
        hoverEnabled: true
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6
    }
}
