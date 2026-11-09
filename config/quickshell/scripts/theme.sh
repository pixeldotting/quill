#!/usr/bin/env bash
# Генератор темы Material You.
#   theme.sh set <картинка>   — поставить обои и перекрасить всё (niri, quickshell, foot, GTK)
#   theme.sh color <#hex>     — тема от seed-цвета, без обоев
#   theme.sh mode dark|light  — переключить тёмную/светлую
#   theme.sh restore          — пересобрать тему из сохранённого состояния (вызывается при старте)
# Схема: MATERIAL_SCHEME=scheme-tonal-spot (по умолчанию, это классический Material You)
#        другие: scheme-expressive scheme-fidelity scheme-content scheme-vibrant scheme-neutral scheme-monochrome
set -euo pipefail

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/material"
mkdir -p "$STATE"
SCHEME="${MATERIAL_SCHEME:-scheme-tonal-spot}"
MODE="$(cat "$STATE/mode" 2>/dev/null || echo dark)"

gtk_sync() {
    command -v gsettings >/dev/null || return 0
    gsettings set org.gnome.desktop.interface color-scheme "prefer-$MODE" 2>/dev/null || true
    if [ "$MODE" = dark ]; then
        gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark" 2>/dev/null || true
    else
        gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3" 2>/dev/null || true
    fi
}

from_wallpaper() { matugen image "$1" -m "$MODE" -t "$SCHEME" >/dev/null; }
from_color()     { matugen color hex "$1" -m "$MODE" -t "$SCHEME" >/dev/null; }

apply_saved() {
    if [ -s "$STATE/wallpaper" ] && [ -f "$(cat "$STATE/wallpaper")" ]; then
        from_wallpaper "$(cat "$STATE/wallpaper")"
    else
        from_color "${SEED:-#6750A4}"
    fi
    gtk_sync
}

case "${1:-}" in
    set)
        img="$(realpath "$2")"
        printf '%s' "$img" > "$STATE/wallpaper"
        from_wallpaper "$img"
        gtk_sync
        ;;
    color)
        rm -f "$STATE/wallpaper"
        from_color "$2"
        gtk_sync
        ;;
    mode)
        MODE="$2"
        printf '%s' "$MODE" > "$STATE/mode"
        apply_saved
        ;;
    restore)
        apply_saved
        ;;
    *)
        sed -n '2,9p' "$0"
        exit 1
        ;;
esac
