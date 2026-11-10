import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Полноэкранный оверлей: клик вне карточки или Esc → dismissed().
// progress (effects) — для opacity; pop (expressive spatial, с перерегулированием) — для scale.
PanelWindow {
    id: root
    property bool open: false
    property bool dim: true
    property real progress: 0
    property real pop: 0
    default property alias content: holder.data
    signal dismissed()

    visible: open
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "qs-overlay"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onOpenChanged: if (open) { fadeAnim.restart(); popAnim.restart() }

    EffectsNumber {
        id: fadeAnim
        target: root
        property: "progress"
        from: 0
        to: 1
        speed: "default"
    }
    SpatialAnim {
        id: popAnim
        target: root
        property: "pop"
        from: 0
        to: 1
        speed: "default"
    }

    Item {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: root.dismissed()

        Rectangle {
            anchors.fill: parent
            color: Theme.scrim
            opacity: root.dim ? 0.32 * root.progress : 0
        }
        MouseArea {
            anchors.fill: parent
            onClicked: root.dismissed()
        }
        Item {
            id: holder
            anchors.fill: parent
        }
    }
}
