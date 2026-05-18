#!/bin/sh
# Bootstrap installer for miniex/btop-theme-damin.
# Run: sh -c "$(curl -fsSL https://raw.githubusercontent.com/miniex/btop-theme-damin/main/install.sh)"
# Or:  sh install.sh   (in-place from a clone)
set -eu

RAW_URL="https://raw.githubusercontent.com/miniex/btop-theme-damin/main"
THEME_NAME="damin"

BTOP_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/btop"
THEMES_DIR="$BTOP_CONFIG/themes"
THEME_DEST="$THEMES_DIR/$THEME_NAME.theme"
CONF_FILE="$BTOP_CONFIG/btop.conf"

if [ -t 1 ]; then
    RESET=$(printf '\033[0m')
    BOLD=$(printf '\033[1m')
    DIM=$(printf '\033[2m')
    SKY=$(printf '\033[38;2;152;171;204m')
    PINK=$(printf '\033[38;2;232;144;176m')
    SKY2=$(printf '\033[38;2;181;197;222m')
    PINK2=$(printf '\033[38;2;245;178;200m')
    YELLOW=$(printf '\033[33m')
    RED=$(printf '\033[31m')
else
    RESET=''
    BOLD=''
    DIM=''
    SKY=''
    PINK=''
    SKY2=''
    PINK2=''
    YELLOW=''
    RED=''
fi

banner() {
    printf '\n'
    printf '   %s%s╭──────────────────────────────────────────────╮%s\n' "$SKY" "$BOLD" "$RESET"
    printf '   %s%s│  %sminiex/btop-theme-damin%s%s%s                     %s%s│%s\n' \
        "$SKY" "$BOLD" "$PINK" "$RESET" "$SKY" "$BOLD" "$SKY" "$BOLD" "$RESET"
    printf '   %s%s│  %sbtop theme installer%s%s%s                        %s%s│%s\n' \
        "$SKY2" "$BOLD" "$PINK2" "$RESET" "$SKY2" "$BOLD" "$SKY2" "$BOLD" "$RESET"
    printf '   %s%s╰──────────────────────────────────────────────╯%s\n' "$PINK" "$BOLD" "$RESET"
    printf '\n'
}

step() { printf '\n%s%s▸ %s%s\n' "$BOLD" "$SKY" "$1" "$RESET"; }
info() { printf '  %sℹ%s  %s\n' "$SKY" "$RESET" "$1"; }
ok() { printf '  %s✓%s  %s\n' "$PINK" "$RESET" "$1"; }
warn() { printf '  %s⚠%s  %s\n' "$YELLOW" "$RESET" "$1"; }
err() { printf '  %s✗%s  %s\n' "$RED" "$RESET" "$1" >&2; }

# /dev/tty so prompts survive `curl | sh`.
read_answer() {
    answer=''
    if { read -r answer </dev/tty; } 2>/dev/null; then
        return 0
    fi
    if read -r answer 2>/dev/null; then
        return 0
    fi
    answer=''
    return 0
}

prompt_yes() {
    printf '  %s?%s  %s %s[y/N]%s ' "$PINK" "$RESET" "$1" "$DIM" "$RESET"
    read_answer
    case "$answer" in
        [yY] | [yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

backup_path() { printf '%s.backup.%s' "$1" "$(date +%Y%m%d-%H%M%S)"; }

fetch() {
    # $1=url $2=dest
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$1" -o "$2"
    else
        wget -qO "$2" "$1"
    fi
}

banner

step "Pre-flight checks"
have_fetcher=0
command -v curl >/dev/null 2>&1 && {
    ok "curl"
    have_fetcher=1
}
command -v wget >/dev/null 2>&1 && {
    ok "wget"
    have_fetcher=1
}

if command -v btop >/dev/null 2>&1; then
    btop_version=$(btop --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || printf '')
    ok "btop ${btop_version:-installed}"
else
    warn "btop not installed — install btop before launching"
fi

# In-place run from inside a clone → use the local damin.theme.
# Only trust IN_PLACE when $0 is a real file (rules out `sh -c` / `curl | sh`,
# where $0 is just `sh` and dirname resolves to CWD).
IN_PLACE=0
LOCAL_THEME=''
if [ -f "$0" ]; then
    SCRIPT_DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd || printf '')
    if [ -n "$SCRIPT_DIR" ] && [ -f "$SCRIPT_DIR/$THEME_NAME.theme" ]; then
        IN_PLACE=1
        LOCAL_THEME="$SCRIPT_DIR/$THEME_NAME.theme"
        info "running in-place from $SCRIPT_DIR"
    fi
fi

if [ "$IN_PLACE" -eq 0 ] && [ "$have_fetcher" -eq 0 ]; then
    err "neither curl nor wget found — install one, or clone the repo and rerun"
    exit 1
fi

step "Install theme"
mkdir -p "$THEMES_DIR"

if [ -e "$THEME_DEST" ]; then
    bk=$(backup_path "$THEME_DEST")
    if [ ! -r /dev/tty ]; then
        mv "$THEME_DEST" "$bk"
        ok "non-interactive — moved existing theme to $bk"
    elif prompt_yes "Replace existing $THEME_DEST? (backup → $bk)"; then
        mv "$THEME_DEST" "$bk"
        ok "existing theme moved to $bk"
    else
        err "aborted — theme already exists at $THEME_DEST"
        exit 1
    fi
fi

if [ "$IN_PLACE" -eq 1 ]; then
    cp "$LOCAL_THEME" "$THEME_DEST"
    ok "copied local $THEME_NAME.theme → $THEME_DEST"
else
    info "fetching $RAW_URL/$THEME_NAME.theme"
    fetch "$RAW_URL/$THEME_NAME.theme" "$THEME_DEST"
    ok "downloaded → $THEME_DEST"
fi

step "Set color_theme in btop.conf"

if [ ! -f "$CONF_FILE" ]; then
    info "no $CONF_FILE yet — pick 'damin' under Options after first launch"
    info 'or set:  color_theme = "damin"'
else
    current=$(grep -E '^color_theme[[:space:]]*=' "$CONF_FILE" | head -n1 \
        | sed -E 's/^color_theme[[:space:]]*=[[:space:]]*//; s/^"//; s/"$//' || printf '')

    if [ "$current" = "$THEME_NAME" ]; then
        ok "already set to $THEME_NAME — nothing to do"
    elif [ ! -r /dev/tty ]; then
        info "non-interactive — leaving btop.conf untouched"
        info 'set:  color_theme = "damin"'
    elif prompt_yes "Rewrite color_theme in $CONF_FILE (currently: ${current:-<unset>})?"; then
        # Portable in-place edit: BSD sed needs a backup suffix, so go via a temp file.
        tmp="$(mktemp)"
        if grep -qE '^color_theme[[:space:]]*=' "$CONF_FILE"; then
            sed -E 's|^color_theme[[:space:]]*=.*|color_theme = "'"$THEME_NAME"'"|' \
                "$CONF_FILE" >"$tmp"
        else
            cp "$CONF_FILE" "$tmp"
            printf '\ncolor_theme = "%s"\n' "$THEME_NAME" >>"$tmp"
        fi
        mv "$tmp" "$CONF_FILE"
        ok "btop.conf updated — restart btop to see it"
    else
        info 'skipped — set:  color_theme = "damin"'
    fi
fi

step "Done"
ok "miniex/btop-theme-damin installed at $THEME_DEST"
printf '\n  %sNext:%s\n' "$BOLD" "$RESET"
printf '    %s•%s launch %s%sbtop%s — themes live in %sOptions → color_theme%s\n' \
    "$PINK" "$RESET" "$SKY" "$BOLD" "$RESET" "$SKY" "$RESET"
printf '    %s•%s pair with %s%sminiex/dotfiles.tmux%s + %s%sdotfiles.kitty%s for the matched palette\n' \
    "$PINK" "$RESET" "$SKY" "$BOLD" "$RESET" "$SKY" "$BOLD" "$RESET"
printf '    %s•%s rerun %s%ssh install.sh%s to refresh the theme file\n\n' \
    "$PINK" "$RESET" "$SKY" "$BOLD" "$RESET"
