# Quill — Material You на Fedora + niri + Quickshell

Весь «рабочий стол» — на Quickshell. Никаких waybar / rofi / wofi / mako / swww / swaylock-подобного.
Цвета — настоящая система Material 3 (Dynamic Color): matugen берёт обои → строит tonal-палитры →
раскладывает по ролям (`primary`, `on_surface`, `surface_container_high` …) → дальше всё красится само.

## Что внутри

| Часть | Чем сделано |
|---|---|
| Композитор | niri (`config/niri/config.kdl`) |
| Панель, лаунчер, уведомления, OSD, центр управления, меню питания, выбор обоев, обои, idle | Quickshell (`config/quickshell`) |
| Генерация цветов | matugen (`config/matugen`) |
| Терминал / GTK | ghostty / GTK3+GTK4 (libadwaita, adw-gtk3) — красятся тем же matugen |

Единственное не-Quickshell: polkit-агент (`polkit-gnome`), без него не работают окна ввода пароля.

## Установка
```
git clone <куда-нибудь> ~/quill && cd ~/quill && ./install.sh
```
Требуется niri с поддержкой `include` в конфиге (свежий, из COPR `yalter/niri`).

## Клавиши (Mod = Super)
- `Mod+Space` лаунчер · `Mod+C` центр управления · `Mod+W` обои · `Mod+Shift+E` питание
- `Mod+Return` терминал · `Mod+Q` закрыть · `Mod+Tab` overview · `Mod+Shift+/` все бинды
- Стрелки/hjkl — фокус, `Mod+Ctrl+…` — перемещение, `Mod+1..9` — рабочие столы
- `Print` / `Ctrl+Print` / `Alt+Print` — скриншоты (встроены в niri)

## Как менять тему
- `Mod+W` → клик по картинке → перекрашивается всё (панель — мгновенно, niri — на лету, новые терминалы/GTK-окна — сразу)
- Светлая/тёмная — тайл «Тема» в центре управления
- Вариант палитры: `MATERIAL_SCHEME=scheme-expressive ~/.config/quickshell/scripts/theme.sh restore`
  (`scheme-tonal-spot` по умолчанию = классический Material You; ещё `scheme-vibrant`, `scheme-fidelity`, `scheme-neutral`, `scheme-monochrome` …)
- Тема от цвета без обоев: `theme.sh color "#6750A4"`

## Структура Quickshell
```
shell.qml            точка входа + IPC (qs ipc call launcher toggle …)
services/            Theme (M3-токены), Niri (воркспейсы/окно), System (звук/сеть/батарея/яркость/MPRIS), UiState, WallpaperState
components/          Icon, Label, IconButton, Pill, Tile, ValueSlider, Overlay
modules/             Bar, Launcher, ControlCenter, Notifications, Osd, PowerMenu, Wallpaper, WallpaperPicker
scripts/theme.sh     обёртка над matugen + gsettings
```
Живая правка: Quickshell перезагружается сам при сохранении QML-файлов.
Логи: `qs log` (или `journalctl --user -b | grep quickshell`).

## Что НЕ сделано
- **Экран блокировки.** Осознанно: на WlSessionLock + PAM легко получить блокировку, из которой не выйти, а проверить это без железа нельзя.
  Пока: `loginctl lock-session` ничего не делает. Можно добавить отдельным шагом.
- Сеть в центре управления — только статус (подключиться к сети нельзя; для этого `nmtui`/`nmcli`).
- Qt-приложения (KDE) не красятся — для этого нужен qt6ct + шаблон matugen.
