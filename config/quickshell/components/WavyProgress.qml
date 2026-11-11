import QtQuick
import qs.services

// Wavy progress indicator (M3 Expressive): the active part is a moving wave, the rest is a flat track
Canvas {
    id: root
    property real value: 0
    property bool animate: true
    property real amplitude: 3
    property real wavelength: 26
    property real thickness: 5
    property real gap: 8
    property color activeColor: Theme.primary
    property color trackColor: Theme.secondaryContainer
    property real phase: 0

    implicitHeight: 18

    onValueChanged: requestPaint()
    onPhaseChanged: requestPaint()
    onActiveColorChanged: requestPaint()
    onTrackColorChanged: requestPaint()
    onWidthChanged: requestPaint()

    NumberAnimation on phase {
        running: root.animate && root.visible
        from: 0
        to: Math.PI * 2
        duration: 1400
        loops: Animation.Infinite
    }

    onPaint: {
        const ctx = getContext("2d")
        ctx.reset()
        ctx.lineCap = "round"
        ctx.lineWidth = thickness
        const r = thickness / 2
        const mid = height / 2
        const xEnd = r + Math.max(0, (width - thickness) * Math.min(1, value))

        // track
        if (xEnd + gap < width - r) {
            ctx.strokeStyle = trackColor
            ctx.beginPath()
            ctx.moveTo(xEnd + gap, mid)
            ctx.lineTo(width - r, mid)
            ctx.stroke()
        }
        // wave
        ctx.strokeStyle = activeColor
        ctx.beginPath()
        const k = (Math.PI * 2) / wavelength
        for (let x = r; x <= xEnd; x += 1) {
            const y = mid + amplitude * Math.sin(x * k - phase)
            if (x === r) ctx.moveTo(x, y); else ctx.lineTo(x, y)
        }
        if (xEnd <= r) ctx.lineTo(r + 0.01, mid)
        ctx.stroke()
    }
}
