import QtQuick
import qs.services

// M3 Expressive effects motion для цвета
ColorAnimation {
    property string speed: "default"
    duration: speed === "slow" ? Theme.durEffectsSlow : speed === "fast" ? Theme.durEffectsFast : Theme.durEffectsDefault
    easing.type: Easing.BezierSpline
    easing.bezierCurve: speed === "slow" ? Theme.effectsSlow : speed === "fast" ? Theme.effectsFast : Theme.effectsDefault
}
