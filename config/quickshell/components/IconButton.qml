import QtQuick
import qs.services

// Круглая иконка-кнопка со state layer (hover 8% / press 12%) по M3
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
        radius: height / 2
        color: root.toggled ? Theme.secondaryContainer : root.fill
        Behavior on color { ColorAnimation { duration: Theme.durShort } }

        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: root.toggled ? Theme.onSecondaryContainer : root.tone
            opacity: ma.pressed ? 0.12 : ma.containsMouse ? 0.08 : 0
            Behavior on opacity { NumberAnimation { duration: 120 } }
        }
    }

    Icon {
        anchors.centerIn: parent
        text: root.icon
        size: root.iconSize
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
