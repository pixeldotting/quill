import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// OSD громкости (срабатывает на клавиши громкости через wpctl)
Scope {
    id: root
    property bool shown: false
    property bool ready: false

    function pop() {
        if (!ready) return
        shown = true
        hideTimer.restart()
    }

    Timer { interval: 2500; running: true; onTriggered: root.ready = true }   // не мигать при старте
    Timer { id: hideTimer; interval: 1600; onTriggered: root.shown = false }

    Connections {
        target: System.sink?.audio ?? null
        function onVolumeChanged() { root.pop() }
        function onMutedChanged() { root.pop() }
    }

    PanelWindow {
        visible: root.shown
        anchors.bottom: true
        margins.bottom: 72
        implicitWidth: 300
        implicitHeight: 64
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}        // клики проходят насквозь
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-osd"

        Rectangle {
            anchors.fill: parent
            radius: height / 2
            color: Theme.surfaceContainerHigh

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 24
                spacing: 14

                Icon { text: System.volumeIcon; size: 26; color: Theme.onSurface }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 12
                    radius: 6
                    color: Theme.secondaryContainer
                    Rectangle {
                        width: parent.width * (System.muted ? 0 : Math.min(1, System.volume))
                        height: parent.height
                        radius: 6
                        color: Theme.primary
                        Behavior on width { NumberAnimation { duration: 120 } }
                    }
                }

                Label {
                    Layout.preferredWidth: 38
                    horizontalAlignment: Text.AlignRight
                    text: System.muted ? "—" : Math.round(System.volume * 100) + "%"
                    font.weight: Font.Medium
                }
            }
        }
    }
}
