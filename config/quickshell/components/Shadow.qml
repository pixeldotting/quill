import QtQuick
import QtQuick.Effects
import qs.services

// Тень по уровням M3 elevation (1…5 = 1, 3, 6, 8, 12 dp). Класть дочерним элементом карточки.
RectangularShadow {
    property int level: 2
    readonly property var dp: [0, 1, 3, 6, 8, 12]

    anchors.fill: parent
    z: -1
    radius: parent.radius
    blur: dp[level] * 3
    offset: Qt.vector2d(0, dp[level] * 0.7)
    color: Qt.alpha(Theme.shadow, 0.32)
}
