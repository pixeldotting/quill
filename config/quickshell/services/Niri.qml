pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Мост к niri через `niri msg -j` + event-stream
Singleton {
    id: root

    property var workspaces: []
    property string windowTitle: ""
    property string appId: ""

    function forOutput(name) {
        return root.workspaces
            .filter(w => w.output === name)
            .sort((a, b) => a.idx - b.idx)
    }

    function focusWorkspace(idx) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", String(idx)])
    }

    function refresh() {
        wsProc.running = true
        winProc.running = true
    }

    Process {
        id: wsProc
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.workspaces = JSON.parse(text) } catch (e) {}
            }
        }
    }

    Process {
        id: winProc
        command: ["niri", "msg", "-j", "focused-window"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const w = JSON.parse(text)
                    root.windowTitle = w ? (w.title ?? "") : ""
                    root.appId = w ? (w.app_id ?? "") : ""
                } catch (e) {
                    root.windowTitle = ""
                    root.appId = ""
                }
            }
        }
    }

    Timer {
        id: debounce
        interval: 60
        onTriggered: root.refresh()
    }

    Process {
        running: true
        command: ["niri", "msg", "-j", "event-stream"]
        stdout: SplitParser {
            onRead: data => debounce.restart()
        }
    }

    Component.onCompleted: refresh()
}
