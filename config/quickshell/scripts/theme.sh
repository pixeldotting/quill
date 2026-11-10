#!/usr/bin/env bash
# Генератор темы Material You (обёртка над matugen).
#   theme.sh set <картинка>      — поставить обои и перекрасить всё (niri, quickshell, ghostty, GTK)
#   theme.sh color <#hex>        — тема от seed-цвета, без обоев
#   theme.sh mode dark|light     — тёмная / светлая
#   theme.sh scheme <имя>        — стиль палитры: scheme-tonal-spot (по умолчанию, классический Material You),
#                                  scheme-expressive, scheme-fruit-salad, scheme-rainbow,
#                                  scheme-fidelity, scheme-content, scheme-neutral, scheme-monochrome
#   theme.sh contrast <-1..1>    — контраст (0 стандартный, 0.5 средний, 1 высокий)
#   theme.sh restore             — пересобрать из сохранённого состояния (вызывается при старте)
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
