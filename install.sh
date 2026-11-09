#!/usr/bin/env bash
# Установка Quill (Material You: niri + Quickshell) на Fedora.
# Конфиги ставятся симлинками — правишь файлы в репозитории, и всё применяется.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"

echo "==> Пакеты"
sudo dnf install -y dnf-plugins-core
sudo dnf copr enable -y yalter/niri
sudo dnf copr enable -y errornointernet/quickshell
sudo dnf copr enable -y scottames/ghostty
sudo dnf copr enable -y heus-sueh/packages || true      # matugen
sudo dnf install -y niri quickshell ghostty brightnessctl wl-clipboard \
    polkit-gnome xdg-desktop-portal-gnome gnome-keyring NetworkManager \
    google-roboto-fonts jetbrains-mono-fonts adw-gtk3-theme

if ! command -v matugen >/dev/null; then
    echo "!! matugen не нашёлся в COPR. Поставь вручную:  cargo install matugen   (или собери релиз с GitHub InioX/matugen)"
fi

echo "==> Шрифт Material Symbols (иконки)"
mkdir -p "$HOME/.local/share/fonts"
if [ ! -f "$HOME/.local/share/fonts/MaterialSymbolsRounded.ttf" ]; then
    curl -L "https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf" \
        -o "$HOME/.local/share/fonts/MaterialSymbolsRounded.ttf"
    fc-cache -f
fi

echo "==> Симлинки"
link() {
    local src="$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        mv "$dst" "$dst.bak.$(date +%s)"
        echo "   бэкап: $dst.bak.*"
    fi
    ln -sfn "$src" "$dst"
    echo "   $dst -> $src"
}
link "$REPO/config/niri/config.kdl"        "$CFG/niri/config.kdl"
link "$REPO/config/quickshell"             "$CFG/quickshell"
link "$REPO/config/matugen/config.toml"    "$CFG/matugen/config.toml"
link "$REPO/config/matugen/templates"      "$CFG/matugen/templates"
link "$REPO/config/ghostty/config"         "$CFG/ghostty/config"
link "$REPO/config/gtk-3.0/settings.ini"   "$CFG/gtk-3.0/settings.ini"
link "$REPO/config/gtk-3.0/gtk.css"        "$CFG/gtk-3.0/gtk.css"
link "$REPO/config/gtk-4.0/settings.ini"   "$CFG/gtk-4.0/settings.ini"
link "$REPO/config/gtk-4.0/gtk.css"        "$CFG/gtk-4.0/gtk.css"
chmod +x "$REPO/config/quickshell/scripts/theme.sh"

mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots" "$HOME/.local/state/material"

echo "==> Первая генерация темы"
if command -v matugen >/dev/null; then
    # niri include требует существующий colors.kdl — генерируем до первого запуска
    "$REPO/config/quickshell/scripts/theme.sh" restore || true
fi

cat <<MSG

Готово.
1. Положи обои в ~/Pictures/Wallpapers
2. Выйди из сессии и выбери «Niri» в менеджере входа (GDM/SDDM)
3. Mod+W — выбрать обои (вся система перекрасится), Mod+Space — лаунчер, Mod+C — центр управления
   Mod+Shift+/ — список всех горячих клавиш
MSG
