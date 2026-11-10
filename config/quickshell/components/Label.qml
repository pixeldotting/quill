import QtQuick
import qs.services

// Текст по типошкале M3. role: displayLarge … labelSmall. emphasized: вариант M3 Expressive (жирнее).
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
