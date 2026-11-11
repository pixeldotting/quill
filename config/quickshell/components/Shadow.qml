import QtQuick
import QtQuick.Effects
import qs.services

// Shadow by M3 elevation level (1…5 = 1, 3, 6, 8, 12 dp). Put it inside a card as a child.
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
