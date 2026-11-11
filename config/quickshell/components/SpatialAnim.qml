import QtQuick
import qs.services

// M3 Expressive spatial motion: size / position / shape. speed: "fast" | "default" | "slow"
NumberAnimation {
    property string speed: "fast"
    duration: speed === "slow" ? Theme.durSpatialSlow : speed === "default" ? Theme.durSpatialDefault : Theme.durSpatialFast
    easing.type: Easing.BezierSpline
    easing.bezierCurve: speed === "slow" ? Theme.spatialSlow : speed === "default" ? Theme.spatialDefault : Theme.spatialFast
}
