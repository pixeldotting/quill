import QtQuick
import qs.services

// Text on the M3 type scale. role: displayLarge … labelSmall. emphasized: the M3 Expressive variant (bolder).
Text {
    property string role: "bodyMedium"
    property bool emphasized: false
    readonly property var t: Theme.typeScale[role]

    font.family: Theme.fontSans
    font.pixelSize: t.size
    font.weight: emphasized ? (t.weight >= 500 ? 800 : 700) : t.weight
    font.letterSpacing: t.track
    lineHeight: t.line
    lineHeightMode: Text.FixedHeight
    color: Theme.onSurface
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
