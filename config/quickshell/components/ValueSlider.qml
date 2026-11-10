import QtQuick
import qs.services

// Слайдер M3 Expressive: толстый трек (44), ручка-«штрих» с зазорами, внешние углы — пилюля, внутренние — 4dp.
Item {
    id: root
    property string icon
    property real value: 0
    signal moved(real v)

    readonly property real trackH: 44
    readonly property real gap: 6
    readonly property real hx: Math.max(0, Math.min(width, width * value))

    implicitHeight: 52

    // активная часть
    Rectangle {
        y: (root.height - root.trackH) / 2
        height: root.trackH
        width: Math.max(0, root.hx - root.gap)
        color: Theme.primary
        topLeftRadius: 22
        bottomLeftRadius: 22
        topRightRadius: Theme.radiusXs
        bottomRightRadius: Theme.radiusXs
    }
    // неактивная часть
    Rectangle {
        x: root.hx + root.gap
        y: (root.height - root.trackH) / 2
        height: root.trackH
        width: Math.max(0, root.width - x)
        color: Theme.secondaryContainer
        topLeftRadius: Theme.radiusXs
        bottomLeftRadius: Theme.radiusXs
        topRightRadius: 22
        bottomRightRadius: 22
    }
    // ручка (при нажатии сужается)
    Rectangle {
        x: Math.max(0, Math.min(root.width - width, root.hx - width / 2))
        anchors.verticalCenter: parent.verticalCenter
        width: ma.pressed ? 2 : 4
        height: root.height
        radius: width / 2
        color: Theme.primary
        Behavior on width { SpatialAnim { speed: "fast" } }
    }

    Icon {
        x: 16
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        size: 22
        color: root.hx > 52 ? Theme.onPrimary : Theme.onSecondaryContainer
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function update(m) { root.moved(Math.max(0, Math.min(1, m.x / width))) }
        onPressed: mouse => update(mouse)
        onPositionChanged: mouse => { if (pressed) update(mouse) }
    }
}
