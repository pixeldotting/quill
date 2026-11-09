import QtQuick
import qs.services

// Иконка из шрифта Material Symbols Rounded (text = имя иконки, напр. "wifi")
Text {
    property real size: 24
    font.family: Theme.fontIcon
    font.pixelSize: size
    color: Theme.onSurface
    verticalAlignment: Text.AlignVCenter
    horizontalAlignment: Text.AlignHCenter
}
