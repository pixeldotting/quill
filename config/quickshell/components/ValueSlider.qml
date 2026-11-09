import QtQuick
import qs.services

// Толстый M3-слайдер: иконка внутри, заливка primary
Item {
    id: root
    property string icon
    property real value: 0
    signal moved(real v)

    implicitHeight: 44

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: Theme.secondaryContainer

        Rectangle {
            width: Math.max(parent.height, parent.width * root.value)
            height: parent.height
            radius: height / 2
            color: Theme.primary
        }

        Icon {
            x: 14
            anchors.verticalCenter: parent.verticalCenter
            text: root.icon
            size: 22
            color: root.value > 0.08 ? Theme.onPrimary : Theme.onSecondaryContainer
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        function update(m) { root.moved(Math.max(0, Math.min(1, m.x / width))) }
        onPressed: mouse => update(mouse)
        onPositionChanged: mouse => { if (pressed) update(mouse) }
    }
}
