import QtQuick
import qs.services

// Иконка-кнопка M3 Expressive: state layers (hover 8% / press 10%), при нажатии форма морфится из круга в скруглённый квадрат
Item {
    id: root
    property string icon
    property real iconSize: 22
    property color tone: Theme.onSurfaceVariant
    property color fill: "transparent"
    property bool toggled: false
    signal clicked()
    signal rightClicked()

    implicitWidth: 40
    implicitHeight: 40

    Rectangle {
        anchors.fill: parent
        radius: ma.pressed ? Theme.radiusMd : height / 2
        color: root.toggled ? Theme.secondaryContainer : root.fill
        Behavior on radius { SpatialAnim { speed: "fast" } }
        Behavior on color { EffectsColor {} }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: root.toggled ? Theme.onSecondaryContainer : root.tone
            opacity: ma.pressed ? Theme.statePress : ma.containsMouse ? Theme.stateHover : 0
            Behavior on opacity { EffectsNumber { speed: "fast" } }
        }
    }

    Icon {
        anchors.centerIn: parent
        text: root.icon
        size: root.iconSize
        filled: root.toggled
        color: root.toggled ? Theme.onSecondaryContainer : root.tone
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: mouse => mouse.button === Qt.RightButton ? root.rightClicked() : root.clicked()
    }
}
