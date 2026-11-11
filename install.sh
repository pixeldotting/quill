#!/usr/bin/env bash
# ╭──────────────────────────────────────────────╮
# │  Quill — installer (Fedora · niri · Quickshell)
# ╰──────────────────────────────────────────────╯
# What it does: asks what to install → shows the plan → asks for confirmation → installs.
# What it does NOT do: run as root, use `curl | sh`, or delete anything without a backup.
# Roll back the configs with: ./install.sh --uninstall
set -Eeuo pipefail
IFS=$'\n\t'
umask 022

# ─────────────────────────── constants ───────────────────────────
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}"
QDATA="$DATA/quill"
QSTATE="$STATE/quill"
BACKUPS="$QDATA/backups/$(date +%Y%m%d-%H%M%S)"
MANIFEST="$QDATA/manifest"
LOG="$QSTATE/install.log"
FONT_DIR="$DATA/fonts"

URL_SYMBOLS='https://github.com/google/material-design-icons/raw/master/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf'
URL_FLEX='https://github.com/google/fonts/raw/main/ofl/robotoflex/RobotoFlex%5BGRAD%2CXOPQ%2CXTRA%2CYOPQ%2CYTAS%2CYTDE%2CYTFI%2CYTLC%2CYTUC%2Copsz%2Cslnt%2Cwdth%2Cwght%5D.ttf'

YES=0; DRY=0; UNINSTALL=0; NO_PKGS=0; NO_FONTS=0; FORCE=0; TERM_ARG=""
TMP=""; SUDO_KEEPALIVE_PID=""

# ─────────────────────────── styling ───────────────────────────
USE_COLOR=0
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ] && [ "${TERM:-dumb}" != "dumb" ]; then USE_COLOR=1; fi
if (( USE_COLOR )); then
    rgb()  { printf '\033[38;2;%s;%s;%sm' "$1" "$2" "$3"; }
    PRI=$(rgb 208 188 255); TER=$(rgb 239 184 200); SEC=$(rgb 204 194 220)
    ERR=$(rgb 242 184 181); OKC=$(rgb 165 214 167); DIM=$(rgb 147 143 153)
    BOLD=$'\033[1m'; BOLD_OFF=$'\033[22m'; RST=$'\033[0m'
    SELBG=$'\033[48;2;79;55;139m'; SELFG=$'\033[38;2;234;221;255m'      # primary-container / on-primary-container
    CHIPBG=$'\033[48;2;54;52;59m'; CHIPFG=$'\033[38;2;230;224;233m'     # surface-container-highest / on-surface
else
    PRI=""; TER=""; SEC=""; ERR=""; OKC=""; DIM=""; BOLD=""; BOLD_OFF=""; RST=""
    SELBG=""; SELFG=""; CHIPBG=""; CHIPFG=""
fi
COLS="$(tput cols 2>/dev/null || echo 80)"
START_TS=$SECONDS

ERR_SHOWN=0
log()  { mkdir -p "$QSTATE"; printf '[%s] %s\n' "$(date +%T)" "$*" >>"$LOG" 2>/dev/null || true; }
ok()   { printf '  %s✔%s %s\n' "$OKC" "$RST" "$*"; log "OK   $*"; }
warn() { printf '  %s▲%s %s\n' "$TER" "$RST" "$*"; log "WARN $*"; }
err()  { printf '  %s✘%s %s\n' "$ERR" "$RST" "$*" >&2; log "ERR  $*"; }
info() { printf '  %s•%s %s\n' "$SEC" "$RST" "$*"; }
dim()  { printf '  %s%s%s\n' "$DIM" "$*" "$RST"; }
die()  { ERR_SHOWN=1; err "$*"; exit 1; }
STEPS_TOTAL=7
# step N "Title" — N=0 means no progress indicator
step() {
    local n=$1; shift
    local bar="" i
    if (( n > 0 )); then
        for (( i = 1; i <= STEPS_TOTAL; i++ )); do if (( i <= n )); then bar+="▰"; else bar+="▱"; fi; done
        printf '\n  %s%s%s  %s%d/%d%s  %s%s%s\n' "$PRI" "$bar" "$RST" "$DIM" "$n" "$STEPS_TOTAL" "$RST" "$BOLD$PRI" "$*" "$RST"
    else
        printf '\n  %s◆%s  %s%s%s\n' "$PRI" "$RST" "$BOLD$PRI" "$*" "$RST"
    fi
    local w=$(( COLS - 4 )); if (( w > 56 )); then w=56; fi; if (( w < 20 )); then w=20; fi
    printf '  %s%s%s\n' "$DIM" "$(printf '─%.0s' $(seq 1 "$w"))" "$RST"
    log "STEP $*"
}

BOX_W=46
box_top() { printf '  %s╭%s╮%s\n' "$PRI" "$(printf '─%.0s' $(seq 1 $BOX_W))" "$RST"; }
box_bot() { printf '  %s╰%s╯%s\n' "$PRI" "$(printf '─%.0s' $(seq 1 $BOX_W))" "$RST"; }
# box_row "visible text" "styled text"
box_row() {
    local LC_ALL=C.UTF-8 plain=$1 styled=$2 pad
    pad=$(( BOX_W - ${#plain} )); if (( pad < 0 )); then pad=0; fi
    printf '  %s│%s%s%*s%s│%s\n' "$PRI" "$RST" "$styled" "$pad" "" "$PRI" "$RST"
}

# grad "text" — horizontal gradient primary → tertiary (M3: #D0BCFF → #EFB8C8)
grad() {
    local LC_ALL=C.UTF-8 text=$1 n i r g b
    if (( ! USE_COLOR )); then printf '%s' "$text"; return 0; fi
    n=${#text}
    for (( i = 0; i < n; i++ )); do
        r=$(( 208 + (239 - 208) * i / (n > 1 ? n - 1 : 1) ))
        g=$(( 188 + (184 - 188) * i / (n > 1 ? n - 1 : 1) ))
        b=$(( 255 + (200 - 255) * i / (n > 1 ? n - 1 : 1) ))
        printf '\033[38;2;%d;%d;%dm%s' "$r" "$g" "$b" "${text:i:1}"
    done
    printf '%s' "$RST"
}

# Palette strip: Material You color pills
palette_strip() {
    if (( ! USE_COLOR )); then return 0; fi
    local c
    printf '  '
    for c in '208;188;255' '204;194;220' '239;184;200' '79;55;139' '99;59;72' '54;52;59'; do
        printf '\033[38;2;%sm▐████▌\033[0m ' "$c"
    done
    printf '\n'
}

banner() {
    printf '\n'
    if (( COLS >= 60 )); then
        printf '   %s✒%s    ' "$TER" "$RST"; grad '▄▀▀▄  █  █  ▀█▀  █    █   '; printf '\n'
        printf '        '; grad '█  █  █  █   █   █    █   '; printf '\n'
        printf '        '; grad '▀▄▄█  ▀▄▄▀  ▄█▄  █▄▄  █▄▄ '; printf '\n'
        printf '\n  %sMaterial You for niri · Fedora · Quickshell · matugen%s\n\n' "$DIM" "$RST"
        palette_strip
    else
        printf '  %s✒%s  ' "$TER" "$RST"; grad 'Quill'; printf '  %s· Material You for niri%s\n' "$DIM" "$RST"
    fi
}

usage() {
    cat <<EOF
Usage: ./install.sh [options]

  -y, --yes             ask no questions, use the defaults
  -n, --dry-run         change nothing, just show what would be done
      --terminal=NAME   ghostty | foot | kitty | alacritty | none
      --no-packages     don't touch dnf / COPR (you install the packages yourself)
      --no-fonts        don't download fonts
      --uninstall       remove the symlinks and restore backups (packages stay)
      --force           don't stop on failed checks (not Fedora, etc.)
  -h, --help            this help
EOF
}

# ─────────────────────────── internals ───────────────────────────
cleanup() {
    local rc=$?  # shellcheck disable=SC2034
    if [ -n "$SUDO_KEEPALIVE_PID" ]; then kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true; fi
    if [ -n "$TMP" ]; then rm -rf "$TMP"; fi
    if (( USE_COLOR )); then printf '\033[?25h'; fi    # restore the cursor
    return 0
}
on_err()  { if (( ! ERR_SHOWN )); then ERR_SHOWN=1; err "Error on line $1. Details: ${LOG/#$HOME/~}"; fi; }
on_int()  { printf '\n'; warn "Interrupted. Changes made so far can be rolled back: ./install.sh --uninstall"; exit 130; }
trap cleanup EXIT
trap 'on_err $LINENO' ERR
trap on_int INT TERM

# In dry-run mode commands are only printed
join() { local IFS=' '; printf '%s' "$*"; }

run() {
    if (( DRY )); then dim "[dry-run] $(join "$@")"; return 0; fi
    log "RUN  $(join "$@")"; "$@"
}

# Run a command in the background with a spinner; its output goes to the log
spin() {
    local msg=$1; shift
    if (( DRY )); then dim "[dry-run] $msg"; return 0; fi
    log "SPIN $msg :: $(join "$@")"
    if (( ! USE_COLOR )) || [ ! -t 1 ]; then
        info "$msg…"; "$@" >>"$LOG" 2>&1; return
    fi
    "$@" >>"$LOG" 2>&1 &
    local pid=$! i=0 rc=0
    local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    printf '\033[?25l'
    while kill -0 "$pid" 2>/dev/null; do
        printf '\r  %s%s%s %s' "$PRI" "${frames[i % 10]}" "$RST" "$msg"
        i=$((i + 1)); sleep 0.08
    done
    wait "$pid" || rc=$?
    printf '\r\033[K\033[?25h'
    if (( rc == 0 )); then ok "$msg"; else err "$msg — failed (log: $LOG)"; fi
    return "$rc"
}

# ─────────────────────────── dialogs ───────────────────────────
interactive() { (( ! YES )) && [ -t 0 ] && [ -t 1 ]; }

# confirm "Question?" Y|N  → exit code 0 = yes
confirm() {
    local q=$1 def=${2:-Y} hint key
    if ! interactive; then if [ "$def" = Y ]; then return 0; else return 1; fi; fi
    if [ "$def" = Y ]; then hint="${SELBG}${SELFG}${BOLD} Y ${RST}${DIM} n ${RST}"; else hint="${DIM} y ${RST}${SELBG}${SELFG}${BOLD} N ${RST}"; fi
    printf '\n  %s❯%s %s%s%s  %s ' "$PRI" "$RST" "$BOLD" "$q" "$RST" "$hint"
    while true; do
        IFS= read -rsn1 key || true
        case "$key" in
            ''|$'\n') if [ "$def" = Y ]; then printf 'yes\n'; return 0; else printf 'no\n'; return 1; fi ;;
            y|Y) printf 'yes\n'; return 0 ;;
            n|N) printf 'no\n'; return 1 ;;
        esac
    done
}

# A list row: "name — description". The selected one is drawn as a pill (primary-container).
# _row i_selected mark name desc name_width
ROW_W=66
# Row width = terminal width - 4 (max 66). Rows must NOT wrap: otherwise "cursor up N lines"
# lands in the wrong place on redraw and the frames get duplicated.
_setw() {
    local c
    c="$(tput cols 2>/dev/null || echo 80)"
    ROW_W=$(( c - 4 ))
    if (( ROW_W > 66 )); then ROW_W=66; fi
    if (( ROW_W < 30 )); then ROW_W=30; fi
}
_row() {
    local LC_ALL=C.UTF-8 sel=$1 mark=$2 name=$3 desc=$4 nw=$5 pad allowed npad
    allowed=$(( ROW_W - nw - 7 ))
    if (( allowed < 4 )); then desc=""
    elif (( ${#desc} > allowed )); then desc="${desc:0:allowed-3}..."; fi
    npad="$(printf '%*s' $(( nw - ${#name} )) '')"
    if [ "$sel" = 1 ]; then
        pad=$(( ROW_W - (${#name} + ${#npad} + ${#desc} + 7) )); if (( pad < 0 )); then pad=0; fi
        printf '  %s%s  %s  %s%s%s  %s%*s%s\033[K\n' "$SELBG" "$SELFG" "$mark" "$BOLD" "$name$npad" "$BOLD_OFF" "$desc" "$pad" "" "$RST"
        return 0
    fi
    printf '    %s  %s%s%s  %s%s%s\033[K\n' "$mark" "$CHIPFG" "$name$npad" "$RST" "$DIM" "$desc" "$RST"
}
_name() { local o=$1; if [[ "$o" == *" — "* ]]; then printf '%s' "${o%% — *}"; else printf '%s' "$o"; fi; }
_desc() { local o=$1; if [[ "$o" == *" — "* ]]; then printf '%s' "${o#* — }"; fi; }
_maxw() { local LC_ALL=C.UTF-8 m=0 o n; for o in "$@"; do n="$(_name "$o")"; if (( ${#n} > m )); then m=${#n}; fi; done; printf '%d' "$m"; }

# menu "Title" default_index "name — description" …  → MENU_RESULT (index)
MENU_RESULT=0
menu() {
    local title=$1 sel=$2; shift 2
    local -a opts=("$@"); local n=${#opts[@]} i key rest nw
    if ! interactive; then MENU_RESULT=$sel; return 0; fi
    _setw
    nw="$(_maxw "${opts[@]}")"
    printf '\n  %s%s%s\n  %s↑ ↓ / j k  ·  Enter%s\n\n' "$BOLD$PRI" "$title" "$RST" "$DIM" "$RST"
    _draw() {
        local m
        for i in "${!opts[@]}"; do
            if (( i == sel )); then m="${PRI}◉${SELFG}"; _row 1 "◉" "$(_name "${opts[i]}")" "$(_desc "${opts[i]}")" "$nw"
            else _row 0 "${DIM}○${RST}" "$(_name "${opts[i]}")" "$(_desc "${opts[i]}")" "$nw"; fi
        done
    }
    printf '\033[?25l'; _draw
    while true; do
        IFS= read -rsn1 key || true
        case "$key" in
            $'\x1b') IFS= read -rsn2 -t 0.05 rest || true
                     case "$rest" in '[A') sel=$(( (sel + n - 1) % n )) ;; '[B') sel=$(( (sel + 1) % n )) ;; esac ;;
            k) sel=$(( (sel + n - 1) % n )) ;;
            j) sel=$(( (sel + 1) % n )) ;;
            [1-9]) if (( key <= n )); then sel=$(( key - 1 )); fi ;;
            ''|$'\n') break ;;
        esac
        printf '\033[%dA' "$n"; _draw
    done
    printf '\033[?25h'
    MENU_RESULT=$sel
}

# multi "Title" "name — description|on" "…|off" …  → MULTI_RESULT[i]=1/0
declare -a MULTI_RESULT=()
multi() {
    local title=$1; shift
    local -a labels=() on=(); local item i cur=0 key rest n nw
    for item in "$@"; do
        labels+=("${item%|*}")
        if [ "${item##*|}" = on ]; then on+=(1); else on+=(0); fi
    done
    n=${#labels[@]}
    if interactive; then
        _setw
        nw="$(_maxw "${labels[@]}")"
        printf '\n  %s%s%s\n  %s↑ ↓  ·  Space toggles  ·  Enter confirms%s\n\n' "$BOLD$PRI" "$title" "$RST" "$DIM" "$RST"
        _mdraw() {
            local mark
            for i in "${!labels[@]}"; do
                if (( on[i] )); then mark="${OKC}●${RST}"; else mark="${DIM}○${RST}"; fi
                if (( i == cur )); then
                    if (( on[i] )); then mark="●"; else mark="○"; fi
                    _row 1 "$mark" "$(_name "${labels[i]}")" "$(_desc "${labels[i]}")" "$nw"
                else
                    _row 0 "$mark" "$(_name "${labels[i]}")" "$(_desc "${labels[i]}")" "$nw"
                fi
            done
        }
        printf '\033[?25l'; _mdraw
        while true; do
            IFS= read -rsn1 key || true
            case "$key" in
                $'\x1b') IFS= read -rsn2 -t 0.05 rest || true
                         case "$rest" in '[A') cur=$(( (cur + n - 1) % n )) ;; '[B') cur=$(( (cur + 1) % n )) ;; esac ;;
                k) cur=$(( (cur + n - 1) % n )) ;;
                j) cur=$(( (cur + 1) % n )) ;;
                ' ') on[cur]=$(( 1 - on[cur] )) ;;
                ''|$'\n') break ;;
            esac
            printf '\033[%dA' "$n"; _mdraw
        done
        printf '\033[?25h'
    fi
    MULTI_RESULT=("${on[@]}")
}

# chips TEXT… — colored "chips" that wrap onto new lines
chips() {
    local LC_ALL=C.UTF-8 c line_len=0 maxw=$(( COLS - 10 ))
    if (( maxw > 58 )); then maxw=58; fi; if (( maxw < 16 )); then maxw=16; fi
    printf '      '
    for c in "$@"; do
        if (( line_len + ${#c} + 3 > maxw && line_len > 0 )); then printf '\n      '; line_len=0; fi
        printf '%s%s %s %s ' "$CHIPBG" "$CHIPFG" "$c" "$RST"
        line_len=$(( line_len + ${#c} + 3 ))
    done
    printf '\n'
}

# ─────────────────────────── terminal data ───────────────────────────
TERM_IDS=(ghostty foot kitty alacritty none)
TERM_PKG=(ghostty foot kitty alacritty "")
TERM_BIN=(ghostty foot kitty alacritty "")
TERM_LABELS=(
    "ghostty — fast, GPU-accelerated, COPR scottames/ghostty"
    "foot — lightweight, Wayland-only, Fedora repos"
    "kitty — GPU-accelerated, feature-rich, Fedora repos"
    "alacritty — minimal, Fedora repos"
    "none — Mod+Return will open nothing"
)

# ─────────────────────────── checks ───────────────────────────
preflight() {
    step 1 "Checks"
    if [ "$(id -u)" -eq 0 ]; then die "Do not run this as root: the configs would end up in /root. I call sudo myself when it is needed."; fi
    ok "running as a regular user (${USER:-$(id -un)})"

    local id="unknown" ver=""
    if [ -r /etc/os-release ]; then
        id="$(. /etc/os-release; printf '%s' "${ID:-unknown}")"
        ver="$(. /etc/os-release; printf '%s' "${VERSION_ID:-}")"
    fi
    if [ "$id" = fedora ]; then ok "Fedora $ver"
    elif (( FORCE )); then warn "this is not Fedora ($id) — continuing because of --force"
    elif (( DRY )); then warn "this is not Fedora ($id) — fine for a --dry-run preview, but a real install needs Fedora"
    else die "This script is made for Fedora (you have: $id). If you know what you are doing, run it with --force."; fi

    if (( ! NO_PKGS )); then
        local tools_ok=1
        command -v sudo >/dev/null || tools_ok=0
        command -v dnf  >/dev/null || tools_ok=0
        if (( tools_ok )); then ok "sudo and dnf are available"
        elif (( DRY )); then warn "sudo or dnf not found — fine for a --dry-run preview"
        else die "sudo and dnf are required for the package step (use --no-packages to skip it)."; fi
    fi

    local f missing=0
    for f in config/niri/config.kdl config/quickshell/shell.qml config/quickshell/scripts/theme.sh \
             config/matugen/config.base.toml config/matugen/templates/colors.json; do
        [ -e "$REPO/$f" ] || { err "missing from the repository: $f"; missing=1; }
    done
    if (( missing )); then die "The repository is incomplete. Download it again: git clone https://github.com/pixeldotting/quill"; fi
    ok "repository files are intact"

    TMP="$(mktemp -d)"
    mkdir -p "$QDATA" "$QSTATE"
    ok "install log: ${LOG/#$HOME/~}"
}

# ─────────────────────────── questions ───────────────────────────
CHOSEN=0                       # index of the chosen terminal
declare -a OPT=(1 1 1 1 0 1)   # components (see multi below)

ask() {
    step 2 "What to install"

    # terminal
    if [ -n "$TERM_ARG" ]; then
        local found=0 i
        for i in "${!TERM_IDS[@]}"; do
            if [ "${TERM_IDS[i]}" = "$TERM_ARG" ]; then CHOSEN=$i; found=1; fi
        done
        (( found )) || die "Unknown terminal: $TERM_ARG (available: $(join "${TERM_IDS[@]}"))"
        ok "terminal: ${TERM_IDS[CHOSEN]} (from --terminal)"
    else
        menu "Which terminal do you want?" 0 "${TERM_LABELS[@]}"
        CHOSEN=$MENU_RESULT
        ok "terminal: ${TERM_IDS[CHOSEN]}"
    fi

    # components
    multi "Extras" \
        "Material Symbols — panel icon font, downloaded from GitHub, ~10 MB|on" \
        "Roboto Flex — Expressive typeface, downloaded from GitHub|on" \
        "adw-gtk3 — GTK3 apps in libadwaita style|on" \
        "polkit agent — password prompts for GUI apps|on" \
        "xwayland-satellite — X11 apps: Steam, legacy programs|off" \
        "Theme now — generate it from the default seed color|on"
    OPT=("${MULTI_RESULT[@]}")
    if (( NO_FONTS )); then OPT[0]=0; OPT[1]=0; fi
}

# ─────────────────────────── plan ───────────────────────────
declare -a PKGS=() COPRS=()
build_plan() {
    PKGS=(niri quickshell matugen brightnessctl wl-clipboard NetworkManager
          xdg-desktop-portal-gnome gnome-keyring google-roboto-fonts jetbrains-mono-fonts)
    COPRS=(yalter/niri errornointernet/quickshell heus-sueh/packages)
    local pkg="${TERM_PKG[CHOSEN]}"
    if [ -n "$pkg" ]; then PKGS+=("$pkg"); fi
    if [ "${TERM_IDS[CHOSEN]}" = ghostty ]; then COPRS+=(scottames/ghostty); fi
    if (( OPT[2] )); then PKGS+=(adw-gtk3-theme); fi
    if (( OPT[3] )); then PKGS+=(polkit-gnome); fi
    if (( OPT[4] )); then PKGS+=(xwayland-satellite); fi
}

show_plan() {
    step 3 "Installation plan"
    if (( NO_PKGS )); then
        printf '\n  %sPackages%s\n  %sSkipped (--no-packages). Install them yourself:%s\n' "$BOLD" "$RST" "$DIM" "$RST"
        chips "${PKGS[@]}"
    else
        printf '\n  %sCOPR repositories%s\n  %sThird-party: built by volunteers, not by Fedora%s\n' "$BOLD" "$RST" "$DIM" "$RST"
        local c
        for c in "${COPRS[@]}"; do
            printf '      %s⬢%s %s%s%s\n        %shttps://copr.fedorainfracloud.org/coprs/%s%s\n' "$TER" "$RST" "$BOLD" "$c" "$RST" "$DIM" "$c" "$RST"
        done
        printf '\n  %sPackages%s\n  %sInstalled with sudo dnf install%s\n' "$BOLD" "$RST" "$DIM" "$RST"
        chips "${PKGS[@]}"
    fi
    if (( OPT[0] || OPT[1] )); then
        printf '\n  %sFonts%s\n  %sDownloaded over https only, file format is verified%s\n' "$BOLD" "$RST" "$DIM" "$RST"
        chips "github.com/google" "material-design-icons" "fonts"
    fi
    local tsuffix=""; if [ -n "${TERM_PKG[CHOSEN]}" ]; then tsuffix=", ${TERM_IDS[CHOSEN]}"; fi
    printf '\n  %sSymlinks in ~/.config%s\n  %sniri, quickshell, matugen, gtk-3.0, gtk-4.0%s%s\n' "$BOLD" "$RST" "$DIM" "$tsuffix" "$RST"
    printf '\n  %sBackups%s\n  %sExisting files move to %s%s\n' "$BOLD" "$RST" "$DIM" "${BACKUPS/#$HOME/~}" "$RST"
    printf '\n  %sUninstall%s\n  %s./install.sh --uninstall%s\n' "$BOLD" "$RST" "$DIM" "$RST"
    if (( DRY )); then printf '\n'; warn "--dry-run mode: nothing will be changed"; fi
    return 0
}
# ─────────────────────────── packages ───────────────────────────
install_packages() {
    if (( NO_PKGS )); then return 0; fi
    step 4 "Packages"
    printf '  %sThese commands will run with sudo:%s\n' "$DIM" "$RST"
    local c
    for c in "${COPRS[@]}"; do dim "sudo dnf copr enable -y $c"; done
    dim "sudo dnf install -y --skip-unavailable $(join "${PKGS[@]}")"
    confirm "Enable the COPR repos and install the packages?" Y || { warn "packages skipped at your request"; return 0; }

    if (( ! DRY )); then
        sudo -v || die "Could not get sudo rights."
        ( while true; do sudo -n true 2>/dev/null; sleep 50; done ) & SUDO_KEEPALIVE_PID=$!
    fi
    run sudo dnf install -y dnf-plugins-core >>"$LOG" 2>&1 || true
    for c in "${COPRS[@]}"; do
        spin "COPR $c" sudo dnf copr enable -y "$c" || warn "could not enable $c — packages from it may fail to install"
    done
    printf '\n'; info "dnf shows its own progress below"
    run sudo dnf install -y --skip-unavailable "${PKGS[@]}" || warn "dnf finished with an error — check the output above"

    if (( ! DRY )); then
        local p miss=()
        for p in "${PKGS[@]}"; do rpm -q "$p" >/dev/null 2>&1 || miss+=("$p"); done
        if (( ${#miss[@]} )); then warn "not installed: $(join "${miss[@]}")"; else ok "all packages installed"; fi
        if ! command -v matugen >/dev/null; then warn "matugen not found. Install it manually: cargo install matugen  (or grab a release from github.com/InioX/matugen)"; fi
    fi
}

# ─────────────────────────── fonts ───────────────────────────
fetch_font() {   # fetch_font URL FILE_NAME
    local url=$1 name=$2 tmp magic size
    tmp="$(mktemp -p "$TMP" font.XXXXXX)"
    curl --proto '=https' --tlsv1.2 -fsSL --retry 2 --connect-timeout 15 --max-filesize 52428800 -o "$tmp" "$url" || return 1
    magic="$(head -c4 "$tmp" | od -An -tx1 | tr -d ' \n')"
    case "$magic" in 00010000|74727565|4f54544f) ;; *) return 2 ;; esac     # TrueType / OpenType
    size="$(stat -c %s "$tmp")"; (( size > 50000 )) || return 3
    install -m 0644 "$tmp" "$FONT_DIR/$name"
}

install_fonts() {
    if (( ! OPT[0] && ! OPT[1] )); then return 0; fi
    step 5 "Fonts"
    command -v curl >/dev/null || { warn "curl is missing — fonts skipped"; return 0; }
    run mkdir -p "$FONT_DIR"
    if (( OPT[0] )); then
        if [ -f "$FONT_DIR/MaterialSymbolsRounded.ttf" ]; then dim "Material Symbols is already installed"
        else spin "Material Symbols Rounded" fetch_font "$URL_SYMBOLS" MaterialSymbolsRounded.ttf \
                || warn "download failed — without it the panel icons will show as squares"; fi
    fi
    if (( OPT[1] )); then
        if [ -f "$FONT_DIR/RobotoFlex.ttf" ]; then dim "Roboto Flex is already installed"
        else spin "Roboto Flex" fetch_font "$URL_FLEX" RobotoFlex.ttf \
                || warn "download failed — Roboto will be used instead"; fi
    fi
    if command -v fc-cache >/dev/null; then spin "refreshing the font cache" fc-cache -f || true; fi
}

# ─────────────────────────── configs ───────────────────────────
manifest_add() { (( DRY )) || printf '%s|%s\n' "$1" "$2" >>"$MANIFEST"; }

backup_path() {   # moves an existing file into the backup directory
    local dst=$1 b
    b="$BACKUPS/$(printf '%s' "$dst" | sed 's#^/##; s#/#__#g')"
    run mkdir -p "$BACKUPS"
    run mv -- "$dst" "$b"
    manifest_add backup "$dst|$b"
    warn "backup: ${dst/#$HOME/~} → ${b/#$HOME/~}"
}

link() {   # link SOURCE TARGET
    local src=$1 dst=$2
    [ -e "$src" ] || die "source does not exist: $src"
    run mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then
        if [ "$(readlink "$dst")" = "$src" ]; then dim "already linked: ${dst/#$HOME/~}"; return 0; fi
        run rm -- "$dst"
    elif [ -e "$dst" ]; then
        backup_path "$dst"
    fi
    run ln -s -- "$src" "$dst"
    manifest_add link "$dst"
    ok "${dst/#$HOME/~}  →  ${src/#$HOME/~}"
}

write_generated() {   # write_generated PATH  (content comes from stdin)
    local dst=$1 body
    body="$(cat)"
    run mkdir -p "$(dirname "$dst")"
    if [ -L "$dst" ]; then run rm -- "$dst"
    elif [ -e "$dst" ] && ! grep -q 'Quill' "$dst" 2>/dev/null; then backup_path "$dst"; fi
    if (( DRY )); then dim "[dry-run] write ${dst/#$HOME/~}"; else printf '%s\n' "$body" >"$dst"; fi
    manifest_add gen "$dst"
    ok "created ${dst/#$HOME/~}"
}

link_configs() {
    step 6 "Configs"
    local t="${TERM_IDS[CHOSEN]}"
    link "$REPO/config/niri/config.kdl"      "$CFG/niri/config.kdl"
    link "$REPO/config/quickshell"           "$CFG/quickshell"
    link "$REPO/config/matugen/templates"    "$CFG/matugen/templates"
    link "$REPO/config/gtk-3.0/settings.ini" "$CFG/gtk-3.0/settings.ini"
    link "$REPO/config/gtk-3.0/gtk.css"      "$CFG/gtk-3.0/gtk.css"
    link "$REPO/config/gtk-4.0/settings.ini" "$CFG/gtk-4.0/settings.ini"
    link "$REPO/config/gtk-4.0/gtk.css"      "$CFG/gtk-4.0/gtk.css"
    case "$t" in
        ghostty)   link "$REPO/config/ghostty/config"        "$CFG/ghostty/config" ;;
        foot)      link "$REPO/config/foot/foot.ini"         "$CFG/foot/foot.ini" ;;
        kitty)     link "$REPO/config/kitty/kitty.conf"      "$CFG/kitty/kitty.conf" ;;
        alacritty) link "$REPO/config/alacritty/alacritty.toml" "$CFG/alacritty/alacritty.toml" ;;
    esac

    # matugen: base + the chosen terminal's fragment (so unused terminals don't get stray directories)
    {
        printf '# Quill — generated by install.sh, do not edit by hand (edit config.base.toml and terminals/ instead)\n'
        cat "$REPO/config/matugen/config.base.toml"
        if [ "$t" != none ]; then cat "$REPO/config/matugen/terminals/$t.toml"; fi
    } | write_generated "$CFG/matugen/config.toml"

    # niri: the terminal for Mod+Return
    {
        printf '// Quill — generated by install.sh (terminal: %s)\n' "$t"
        if [ "$t" = none ]; then printf 'binds {}\n'
        else printf 'binds {\n    Mod+Return hotkey-overlay-title="Terminal" { spawn "%s"; }\n}\n' "${TERM_BIN[CHOSEN]}"; fi
    } | write_generated "$CFG/niri/terminal.kdl"

    # niri include files: niri may look for them next to the real config.kdl (in the repository),
    # or next to the symlink. We put links in both places so the config can't break.
    local f
    for f in colors.kdl terminal.kdl; do
        run ln -sfn -- "$CFG/niri/$f" "$REPO/config/niri/$f"
    done
    ok "niri include files are reachable from both places"

    run mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Screenshots" "$STATE/material"
    run chmod +x "$REPO/config/quickshell/scripts/theme.sh"
    printf 'terminal=%s\n' "$t" >"$QSTATE/choices" 2>/dev/null || true
}

generate_theme() {
    if (( ! OPT[5] )); then return 0; fi
    step 7 "Theme"
    if ! command -v matugen >/dev/null; then warn "matugen is not installed — generate the theme later with: theme.sh restore"; return 0; fi
    if (( DRY )); then dim "[dry-run] theme.sh restore"; return 0; fi
    spin "generating Material You from the seed color #6750A4" "$REPO/config/quickshell/scripts/theme.sh" restore \
        || warn "theme.sh finished with an error (log: $LOG)"
    if command -v niri >/dev/null; then
        if niri validate -c "$CFG/niri/config.kdl" >>"$LOG" 2>&1; then ok "niri config passes validation (niri validate)"
        else warn "niri validate found a problem in the config — see the log: $LOG"; fi
    fi
}

# ─────────────────────────── uninstall ───────────────────────────
uninstall() {
    banner
    step 0 "Rolling back Quill"
    [ -f "$MANIFEST" ] || { warn "manifest not found ($MANIFEST) — nothing to roll back"; return 0; }
    info "the symlinks and generated files from the manifest will be removed, and backups put back"
    info "packages and fonts stay"
    if (( ! YES )); then confirm "Continue?" N || { warn "cancelled"; return 0; }; fi
    local kind rest line dst b
    while IFS= read -r line; do
        kind="${line%%|*}"; rest="${line#*|}"
        case "$kind" in
            link) if [ -L "$rest" ]; then run rm -- "$rest"; ok "removed link ${rest/#$HOME/~}"; fi ;;
            gen)  if [ -f "$rest" ]; then run rm -- "$rest"; ok "removed ${rest/#$HOME/~}"; fi ;;
        esac
    done < <(tac "$MANIFEST")
    while IFS= read -r line; do
        kind="${line%%|*}"; rest="${line#*|}"
        if [ "$kind" = backup ]; then
            dst="${rest%%|*}"; b="${rest#*|}"
            if [ -e "$b" ] && [ ! -e "$dst" ]; then run mv -- "$b" "$dst"; ok "restored ${dst/#$HOME/~}"; fi
        fi
    done <"$MANIFEST"
    rm -f "$REPO/config/niri/colors.kdl" "$REPO/config/niri/terminal.kdl"
    (( DRY )) || rm -f "$MANIFEST"
    printf '\n'; ok "done"
}

# ─────────────────────────── finish ───────────────────────────
summary() {
    local took=$(( SECONDS - START_TS ))
    printf '\n'
    box_top
    box_row "  ✔  Done in ${took} s" "  ${OKC}${BOLD}✔  Done${RST}${DIM} in ${took} s${RST}"
    box_bot
    printf '\n  %sNext steps%s\n\n' "$BOLD$PRI" "$RST"
    printf '   %s①%s  put some wallpapers in %s~/Pictures/Wallpapers%s\n' "$TER" "$RST" "$BOLD" "$RST"
    printf '   %s②%s  log out and pick %sNiri%s on the login screen\n' "$TER" "$RST" "$BOLD" "$RST"
    printf '   %s③%s  %sMod+W%s wallpapers & style  ·  %sMod+Space%s launcher  ·  %sMod+C%s control center\n' "$TER" "$RST" "$BOLD" "$RST" "$BOLD" "$RST" "$BOLD" "$RST"
    printf '   %s④%s  %sMod+Shift+/%s — all hotkeys\n\n' "$TER" "$RST" "$BOLD" "$RST"
    palette_strip
    printf '\n'
    dim "log:        ${LOG/#$HOME/~}"
    dim "backups:    ${BACKUPS/#$HOME/~}  (if anything was replaced)"
    dim "uninstall:  ./install.sh --uninstall"
    printf '\n'
}

# ─────────────────────────── main ───────────────────────────
main() {
    local a
    for a in "$@"; do
        case "$a" in
            -y|--yes) YES=1 ;;
            -n|--dry-run) DRY=1 ;;
            --terminal=*) TERM_ARG="${a#*=}" ;;
            --no-packages) NO_PKGS=1 ;;
            --no-fonts) NO_FONTS=1 ;;
            --uninstall) UNINSTALL=1 ;;
            --force) FORCE=1 ;;
            -h|--help) usage; exit 0 ;;
            *) usage; die "Unknown option: $a" ;;
        esac
    done

    if (( UNINSTALL )); then mkdir -p "$QDATA" "$QSTATE"; uninstall; exit 0; fi

    banner
    preflight
    ask
    build_plan
    show_plan
    confirm "Start the installation?" Y || { warn "Cancelled — nothing was changed."; exit 0; }

    install_packages
    install_fonts
    link_configs
    generate_theme
    summary
}
main "$@"
