<div align="center">

<img src="assets/logo.svg" width="112" alt="Quill logo">

# Quill

Material You desktop for niri and Quickshell, on Fedora.

![Fedora](https://img.shields.io/badge/Fedora-51A2DA?style=flat-square&logo=fedora&logoColor=white)
![niri](https://img.shields.io/badge/compositor-niri-6750A4?style=flat-square)
![Quickshell](https://img.shields.io/badge/shell-Quickshell-4F378B?style=flat-square)
![Material 3](https://img.shields.io/badge/design-Material_3_Expressive-D0BCFF?style=flat-square&labelColor=381E72)
![License](https://img.shields.io/badge/license-MIT-EFB8C8?style=flat-square&labelColor=492532)

<img src="assets/banner.svg" alt="Quill">

</div>

## Overview

Quill is a complete desktop shell for the [niri](https://github.com/YaLTeR/niri) compositor, written in QML on top of [Quickshell](https://quickshell.org). It replaces waybar, rofi, wofi, mako and swww with a single, consistent shell.

Colors are generated from your wallpaper with [matugen](https://github.com/InioX/matugen). The design follows the whole Material 3 system, not only its palette: shape, typography, motion, state layers and elevation are all implemented. Changing the wallpaper recolors the shell, niri, your terminal and GTK applications.

## Design system

| Layer | Implementation |
|---|---|
| Color | Wallpaper to tonal palettes to 30+ color roles (`primary`, `on_surface`, `surface_container_high`, ...). Seven palette styles and three contrast levels. |
| Shape | The M3 corner scale: 4, 8, 12, 16, 20, 28, 32, 48, full. Buttons, tiles and list items change shape on press and selection. |
| Typography | All 15 M3 type roles with real sizes, line heights and tracking. Roboto Flex, with emphasized variants. |
| Motion | M3 Expressive tokens: spring-like spatial motion for size and shape, plain effects motion for color and opacity. |
| State layers | Hover 8%, focus and press 10%. |
| Elevation | Tonal surfaces, plus shadows for levels 1 to 5. |
| Components | Search bar, segmented list, toggle tiles, Expressive slider, filter chips, wavy progress indicator, filled icons for selected state. |

## Components

| Part | Description |
|---|---|
| Bar | Three islands: workspaces, clock, tray and status. |
| Launcher | Application search. |
| Notifications | Notification daemon with actions, urgency and do-not-disturb. |
| Control center | Network, theme, do-not-disturb, volume, brightness, media. |
| OSD | Volume indicator. |
| Style | Wallpaper, palette style and contrast picker. |
| Power menu | Sleep, log out, restart, shut down. |
| Wallpaper, idle | Rendered and handled by Quickshell. |
| Terminal and GTK | ghostty, foot, kitty or alacritty (chosen at install time), plus GTK 3 and 4, all recolored by the same matugen run. |

The only piece that is not part of the shell is the polkit agent (`polkit-gnome`), which GUI applications need for password prompts.

## Installation

```bash
git clone https://github.com/pixeldotting/quill ~/quill
cd ~/quill
./install.sh
```

Run it from the session you already have: GNOME on a fresh Fedora Workstation install is fine, and so is a plain TTY. niri does not need to be running, because the installer is what installs it.

The installer asks what to install, shows a plan and waits for confirmation:

1. Terminal: ghostty, foot, kitty, alacritty or none.
2. Extras: fonts, adw-gtk3, polkit agent, xwayland-satellite.
3. Plan: which COPR repositories are enabled and which packages and files are touched.

After it finishes, put wallpapers into `~/Pictures/Wallpapers`, log out of GNOME, choose the Niri session on the login screen (the gear icon next to the Sign In button in GDM) and press `Mod+W`.

Note: the theme step also sets GNOME's color scheme and the adw-gtk3 theme through `gsettings`, so GTK apps in GNOME will pick up the Quill palette the next time they start.

Requires a niri version that supports `include` in its config. The `yalter/niri` COPR provides one. Validate the config with `niri validate`.

### Installer safety

- Never runs as root. `sudo` is used only for `dnf`, after the exact commands are shown and confirmed.
- COPR repositories are third-party. Each one is listed with a link before it is enabled.
- Fonts are downloaded over HTTPS into a temporary directory, with a file format check and a size limit.
- Existing files are never overwritten. They are moved to `~/.local/share/quill/backups/`.
- Every change is recorded in a manifest. `./install.sh --uninstall` removes the links and restores the backups.
- Safe to run more than once. The log is written to `~/.local/state/quill/install.log`.

### Options

| Option | Effect |
|---|---|
| `-y`, `--yes` | Ask nothing, use defaults. |
| `-n`, `--dry-run` | Show what would be done without changing anything. |
| `--terminal=NAME` | `ghostty`, `foot`, `kitty`, `alacritty` or `none`. |
| `--no-packages` | Do not touch dnf or COPR. |
| `--no-fonts` | Do not download fonts. |
| `--uninstall` | Remove the links and restore backups. Packages are kept. |
| `--force` | Continue past failed checks, for example on a non-Fedora system. |

## Hotkeys

`Mod` is the Super key. `Mod+Shift+/` shows the full list inside niri.

| Keys | Action |
|---|---|
| `Mod+Space` | Launcher |
| `Mod+C` | Control center |
| `Mod+W` | Wallpapers and style |
| `Mod+Shift+E` | Power menu |
| `Mod+Return` | Terminal |
| `Mod+Q` | Close window |
| `Mod+Tab` | Overview |
| `Mod+Left`, `Mod+Right` (or `H`, `L`) | Focus column |
| `Mod+Ctrl+Left`, `Mod+Ctrl+Right` | Move column |
| `Mod+1` to `Mod+9` | Switch workspace |
| `Mod+F`, `Mod+Shift+F` | Maximize column, fullscreen |
| `Print`, `Ctrl+Print`, `Alt+Print` | Screenshot: region, screen, window |

## Theming

`Mod+W` opens the style window: pick a wallpaper, a palette style (Tonal spot, Expressive, Fruit salad, Rainbow, Fidelity, Neutral, Monochrome) and a contrast level. The light and dark switch is in the control center.

The same controls are available from a shell:

```bash
THEME=~/.config/quickshell/scripts/theme.sh
$THEME set ~/Pictures/Wallpapers/image.jpg
$THEME color "#6750A4"               # seed color instead of a wallpaper
$THEME scheme scheme-expressive
$THEME contrast 0.5
$THEME mode light
```

## Repository layout

```
install.sh
assets/                    logo, banner, screenshots
config/
  niri/config.kdl
  matugen/                 config.base.toml, terminals/, templates/
  ghostty/  foot/  kitty/  alacritty/
  gtk-3.0/  gtk-4.0/
  quickshell/
    shell.qml              entry point and IPC
    services/              Theme (M3 tokens), Niri, System, UiState, WallpaperState
    components/            Icon, Label, IconButton, Pill, Tile, Chip, ValueSlider,
                           WavyProgress, Shadow, Overlay, motion helpers
    modules/               Bar, Launcher, ControlCenter, Notifications, Osd,
                           PowerMenu, WallpaperPicker, Wallpaper
    scripts/theme.sh
```

Quickshell reloads automatically when a QML file is saved. Logs: `qs log`.

## Known limitations

- No lock screen. A mistake in session-lock or PAM code can leave a session locked with no way out, so it is left out until it can be tested properly.
- The network tile shows status only. Use `nmtui` or `nmcli` to connect.
- Qt and KDE applications are not recolored. That needs qt6ct and an additional matugen template.
- Written without testing on a live system. If something fails to start, open an issue with the output of `qs log`.

## Credits

[niri](https://github.com/YaLTeR/niri), [Quickshell](https://quickshell.org), [matugen](https://github.com/InioX/matugen), [Material Design 3](https://m3.material.io), [ghostty](https://ghostty.org), [foot](https://codeberg.org/dnkl/foot), [kitty](https://sw.kovidgoyal.net/kitty/), [alacritty](https://alacritty.org).

## License

MIT. See [LICENSE](LICENSE).
