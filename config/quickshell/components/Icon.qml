import QtQuick
import qs.services

// Material Symbols Rounded (variable). text = icon name. filled = the FILL axis (selected state in M3).
Text {
    property real size: 24
    property bool filled: false
    font.family: Theme.fontIcon
    font.pixelSize: size
    font.variableAxes: ({ "FILL": filled ? 1 : 0, "wght": 400, "opsz": Math.max(20, Math.min(48, size)) })
    color: Theme.onSurface
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
