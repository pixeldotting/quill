#!/usr/bin/env bash
# Material You theme generator (a wrapper around matugen).
#   theme.sh set <image>         — set the wallpaper and recolor everything (niri, quickshell, terminal, GTK)
#   theme.sh color <#hex>        — theme from a seed color, no wallpaper
#   theme.sh mode dark|light     — dark / light
#   theme.sh scheme <name>       — palette style: scheme-tonal-spot (default, classic Material You),
#                                  scheme-expressive, scheme-fruit-salad, scheme-rainbow,
#                                  scheme-fidelity, scheme-content, scheme-neutral, scheme-monochrome
#   theme.sh contrast <-1..1>    — contrast (0 standard, 0.5 medium, 1 high)
#   theme.sh restore             — rebuild from the saved state (runs at startup)
set -euo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/material"
mkdir -p "$STATE"

read_state() { cat "$STATE/$1" 2>/dev/null || echo "$2"; }
MODE="$(read_state mode dark)"
SCHEME="$(read_state scheme scheme-tonal-spot)"
CONTRAST="$(read_state contrast 0)"

gtk_sync() {
    command -v gsettings >/dev/null || return 0
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE" 2>/dev/null || true
    if [ "$MODE" = dark ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark" 2>/dev/null || true
    else
        gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3" 2>/dev/null || true
    fi
}

opts=(-m "$MODE" -t "$SCHEME" --contrast "$CONTRAST")
from_wallpaper() { matugen image "$1" "${opts[@]}" >/dev/null; }
from_color()     { matugen color hex "$1" "${opts[@]}" >/dev/null; }

apply_saved() {
    if [ -s "$STATE/wallpaper" ] && [ -f "$(cat "$STATE/wallpaper")" ]; then
        from_wallpaper "$(cat "$STATE/wallpaper")"
    else
        from_color "$(read_state seed '#6750A4')"
    fi
    gtk_sync
}

case "${1:-}" in
    set)
        img="$(realpath "$2")"
        printf '%s' "$img" > "$STATE/wallpaper"
        apply_saved
        ;;
    color)
        rm -f "$STATE/wallpaper"
        printf '%s' "$2" > "$STATE/seed"
        apply_saved
        ;;
    mode)     printf '%s' "$2" > "$STATE/mode";     MODE="$2";     opts=(-m "$MODE" -t "$SCHEME" --contrast "$CONTRAST"); apply_saved ;;
    scheme)   printf '%s' "$2" > "$STATE/scheme";   SCHEME="$2";   opts=(-m "$MODE" -t "$SCHEME" --contrast "$CONTRAST"); apply_saved ;;
    contrast) printf '%s' "$2" > "$STATE/contrast"; CONTRAST="$2"; opts=(-m "$MODE" -t "$SCHEME" --contrast "$CONTRAST"); apply_saved ;;
    restore)  apply_saved ;;
    *)
        sed -n '2,13p' "$0"
        exit 1
        ;;
esac
