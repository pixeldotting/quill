pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Material 3 (Material You) токены.
// Цвета читаются из ~/.local/state/material/colors.json (его пишет matugen)
// и обновляются на лету. Значения по умолчанию — baseline-тема M3 (dark).
Singleton {
    id: root

    // ---- цветовые роли ----
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

    // ---- форма (M3 shape scale) ----
    readonly property int radiusXs: 4
    readonly property int radiusSm: 8
    readonly property int radiusMd: 12
    readonly property int radiusLg: 16
    readonly property int radiusXl: 28

    // ---- типографика ----
    readonly property string fontSans: "Roboto"
    readonly property string fontIcon: "Material Symbols Rounded"

    // ---- движение (M3 emphasized easing) ----
    readonly property var emphasized: [0.2, 0, 0, 1, 1, 1]
    readonly property int durShort: 150
    readonly property int durMedium: 300

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
