pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Material 3 / Material You tokens: color, shape, typography, motion, state layers, elevation.
// Colors are read from ~/.local/state/material/colors.json (written by matugen) and update live.
// Defaults are the M3 baseline theme (dark).
Singleton {
    id: root

    // ================= COLOR (30+ roles) =================
    readonly property color primary: c.primary
    readonly property color onPrimary: c.on_primary
    readonly property color primaryContainer: c.primary_container
    readonly property color onPrimaryContainer: c.on_primary_container
    readonly property color secondary: c.secondary
    readonly property color onSecondary: c.on_secondary
    readonly property color secondaryContainer: c.secondary_container
    readonly property color onSecondaryContainer: c.on_secondary_container
    readonly property color tertiary: c.tertiary
    readonly property color onTertiary: c.on_tertiary
    readonly property color tertiaryContainer: c.tertiary_container
    readonly property color onTertiaryContainer: c.on_tertiary_container
    readonly property color error: c.error
    readonly property color onError: c.on_error
    readonly property color errorContainer: c.error_container
    readonly property color onErrorContainer: c.on_error_container
    readonly property color surface: c.surface
    readonly property color onSurface: c.on_surface
    readonly property color surfaceVariant: c.surface_variant
    readonly property color onSurfaceVariant: c.on_surface_variant
    readonly property color surfaceDim: c.surface_dim
    readonly property color surfaceBright: c.surface_bright
    readonly property color surfaceContainerLowest: c.surface_container_lowest
    readonly property color surfaceContainerLow: c.surface_container_low
    readonly property color surfaceContainer: c.surface_container
    readonly property color surfaceContainerHigh: c.surface_container_high
    readonly property color surfaceContainerHighest: c.surface_container_highest
    readonly property color outline: c.outline
    readonly property color outlineVariant: c.outline_variant
    readonly property color inverseSurface: c.inverse_surface
    readonly property color inverseOnSurface: c.inverse_on_surface
    readonly property color inversePrimary: c.inverse_primary
    readonly property color scrim: c.scrim
    readonly property color shadow: c.shadow

    // ================= SHAPE: M3 shape scale (+ Expressive) =================
    readonly property int radiusNone: 0
    readonly property int radiusXs: 4
    readonly property int radiusSm: 8
    readonly property int radiusMd: 12
    readonly property int radiusLg: 16
    readonly property int radiusLgInc: 20     // large-increased (Expressive)
    readonly property int radiusXl: 28
    readonly property int radiusXlInc: 32     // extra-large-increased (Expressive)
    readonly property int radiusXxl: 48
    // full = height / 2

    // ================= TYPOGRAPHY: the 15 M3 roles =================
    // Roboto Flex is the M3 Expressive typeface; falls back to Roboto if it isn't installed.
    readonly property string fontSans: Qt.fontFamilies().indexOf("Roboto Flex") >= 0 ? "Roboto Flex" : "Roboto"
    readonly property string fontIcon: "Material Symbols Rounded"
    readonly property var typeScale: ({
        displayLarge: { size: 57, line: 64, weight: 400, track: -0.25 },
        displayMedium: { size: 45, line: 52, weight: 400, track: 0 },
        displaySmall: { size: 36, line: 44, weight: 400, track: 0 },
        headlineLarge: { size: 32, line: 40, weight: 400, track: 0 },
        headlineMedium: { size: 28, line: 36, weight: 400, track: 0 },
        headlineSmall: { size: 24, line: 32, weight: 400, track: 0 },
        titleLarge: { size: 22, line: 28, weight: 400, track: 0 },
        titleMedium: { size: 16, line: 24, weight: 500, track: 0.15 },
        titleSmall: { size: 14, line: 20, weight: 500, track: 0.1 },
        bodyLarge: { size: 16, line: 24, weight: 400, track: 0.5 },
        bodyMedium: { size: 14, line: 20, weight: 400, track: 0.25 },
        bodySmall: { size: 12, line: 16, weight: 400, track: 0.4 },
        labelLarge: { size: 14, line: 20, weight: 500, track: 0.1 },
        labelMedium: { size: 12, line: 16, weight: 500, track: 0.5 },
        labelSmall: { size: 11, line: 16, weight: 500, track: 0.5 }
    })

    // ================= MOTION: M3 Expressive =================
    // spatial (size, position, shape morph) — a spring with slight overshoot;
    // effects (color, opacity) — no overshoot.
    readonly property var spatialFast:    [0.42, 1.67, 0.21, 0.90, 1, 1]
    readonly property var spatialDefault: [0.38, 1.21, 0.22, 1.00, 1, 1]
    readonly property var spatialSlow:    [0.39, 1.29, 0.35, 0.98, 1, 1]
    readonly property var effectsFast:    [0.31, 0.94, 0.34, 1.00, 1, 1]
    readonly property var effectsDefault: [0.34, 0.80, 0.34, 1.00, 1, 1]
    readonly property var effectsSlow:    [0.34, 0.88, 0.34, 1.00, 1, 1]
    readonly property int durSpatialFast: 350
    readonly property int durSpatialDefault: 500
    readonly property int durSpatialSlow: 650
    readonly property int durEffectsFast: 150
    readonly property int durEffectsDefault: 200
    readonly property int durEffectsSlow: 300

    // ================= STATE LAYERS =================
    readonly property real stateHover: 0.08
    readonly property real stateFocus: 0.10
    readonly property real statePress: 0.10
    readonly property real stateDrag: 0.16
    readonly property real disabledContent: 0.38

    FileView {
        path: Quickshell.env("HOME") + "/.local/state/material/colors.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()

        JsonAdapter {
            id: c
            property string primary: "#D0BCFF"
            property string on_primary: "#381E72"
            property string primary_container: "#4F378B"
            property string on_primary_container: "#EADDFF"
            property string secondary: "#CCC2DC"
            property string on_secondary: "#332D41"
            property string secondary_container: "#4A4458"
            property string on_secondary_container: "#E8DEF8"
            property string tertiary: "#EFB8C8"
            property string on_tertiary: "#492532"
            property string tertiary_container: "#633B48"
            property string on_tertiary_container: "#FFD8E4"
            property string error: "#F2B8B5"
            property string on_error: "#601410"
            property string error_container: "#8C1D18"
            property string on_error_container: "#F9DEDC"
            property string surface: "#141218"
            property string on_surface: "#E6E0E9"
            property string surface_variant: "#49454F"
            property string on_surface_variant: "#CAC4D0"
            property string surface_dim: "#141218"
            property string surface_bright: "#3B383E"
            property string surface_container_lowest: "#0F0D13"
            property string surface_container_low: "#1D1B20"
            property string surface_container: "#211F26"
            property string surface_container_high: "#2B2930"
            property string surface_container_highest: "#36343B"
            property string outline: "#938F99"
            property string outline_variant: "#49454F"
            property string inverse_surface: "#E6E0E9"
            property string inverse_on_surface: "#322F35"
            property string inverse_primary: "#6750A4"
            property string scrim: "#000000"
            property string shadow: "#000000"
        }
    }
}
