import QtQuick
import QtQuick.Layouts
import qs.services

// M3 filter chip: selected = secondary-container + checkmark
Rectangle {
    id: root
    property string text
    property bool selected: false
    signal clicked()

    implicitHeight: 32
    implicitWidth: chipRow.implicitWidth + 24
    radius: Theme.radiusSm
    color: selected ? Theme.secondaryContainer : "transparent"
    border.width: selected ? 0 : 1
    border.color: Theme.outlineVariant
    Behavior on color { EffectsColor { speed: "fast" } }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: Theme.onSurfaceVariant
        opacity: ma.pressed ? Theme.statePress : ma.containsMouse ? Theme.stateHover : 0
    }

    RowLayout {
        id: chipRow
        anchors.centerIn: parent
        spacing: 6
        Icon {
            visible: root.selected
            text: "check"
            size: 18
            color: Theme.onSecondaryContainer
        }
        Label {
            role: "labelLarge"
            text: root.text
            color: root.selected ? Theme.onSecondaryContainer : Theme.onSurfaceVariant
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
