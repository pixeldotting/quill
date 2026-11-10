import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.services
import qs.components

// OSD громкости с волнистым индикатором (M3 Expressive). Срабатывает на клавиши громкости (wpctl).
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
    Timer { id: hideTimer; interval: 1800; onTriggered: root.shown = false }

    Connections {
        target: System.sink?.audio ?? null
        function onVolumeChanged() { root.pop() }
        function onMutedChanged() { root.pop() }
    }

    PanelWindow {
        visible: root.shown
        anchors.bottom: true
        margins.bottom: 48                  // 24px внутреннего поля под тень
        implicitWidth: 348
        implicitHeight: 112
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        mask: Region {}                     // клики проходят насквозь
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "qs-osd"

        Rectangle {
            id: box
            anchors.centerIn: parent
            width: 300
            height: 64
            radius: height / 2
            color: Theme.surfaceContainerHigh
            Shadow { level: 3 }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 24
                spacing: 14

                Icon { text: System.volumeIcon; size: 26; filled: true; color: Theme.onSurface }

                WavyProgress {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    value: System.muted ? 0 : Math.min(1, System.volume)
                    animate: root.shown && !System.muted
                }

                Label {
                    Layout.preferredWidth: 40
                    horizontalAlignment: Text.AlignRight
                    role: "labelLarge"
                    emphasized: true
                    text: System.muted ? "—" : Math.round(System.volume * 100) + "%"
                }
            }
        }
    }
}
