import QtQuick
import QtQuick.Layouts
import qs.services

// «Островок» панели: поверхность surface-container, радиус full
Rectangle {
    id: root
    default property alias content: row.data
    property alias spacing: row.spacing
    property real padding: 8
    property bool clickable: false
    signal clicked()

    implicitHeight: 40
    implicitWidth: row.implicitWidth + padding * 2
    radius: ma.pressed && clickable ? Theme.radiusLg : height / 2
    color: Theme.surfaceContainer
    Behavior on radius { SpatialAnim { speed: "fast" } }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Theme.onSurface
        opacity: root.clickable ? (ma.pressed ? Theme.statePress : ma.containsMouse ? Theme.stateHover : 0) : 0
        Behavior on opacity { EffectsNumber { speed: "fast" } }
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
