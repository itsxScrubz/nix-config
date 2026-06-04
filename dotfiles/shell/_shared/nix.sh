# ~ Nix specific aliases and functions.
# Only sourced when Nix is installed on the system.
# ! ONLY necessary when this config is NOT symlink managed by home-manager.
# * If you are not managing these dotfiles via home-manager (manual management)
# * then you MUST uncomment this and manually set the full path to this flake
# * in order for the flake build aliases [fbs/fbh] included in this config to work.
# ? Using your own dotfiles instead of mine?? Just copy over nix.sh into your
# ? shell config as well as the following export if you aren't managing dotfiles
# ? via home-manager.
# export FLAKE_DIR="$HOME/path/to/your/flake"
#
# Nix flake aliases.
alias fbh="flake build home"
alias fbs="flake build system"
alias fbu="flake build update"

# Nix garbage collection.
# Store optimisation happens automatically at build time via `nix.settings.auto-optimise-store`,
# so this function only reclaims unreferenced paths and doesn't run `nix store optimise`.
# Usage:
#   fgc        → purge ALL old generations (user + system)
#   fgc <N>    → keep only the last N generations (user + system)
fgc() {
    local keep="${1:-}"
    if [[ -n "$keep" ]]; then
        if ! [[ "$keep" =~ ^[0-9]+$ ]]; then
            echo "Usage: fgc [N]   (N = number of recent generations to keep)"
            return 1
        fi
        echo "==> Keeping last $keep generations on all profiles..."
        # User env profile.
        nix-env --delete-generations "+$keep" 2>/dev/null || true
        # Home-manager profile(s) under XDG state dir.
        if [[ -d "$HOME/.local/state/nix/profiles" ]]; then
            for p in "$HOME"/.local/state/nix/profiles/home-manager*; do
                [[ -e "$p" && ! -L "$p" ]] || [[ -L "$p" ]] || continue
                nix-env -p "$p" --delete-generations "+$keep" 2>/dev/null || true
            done
        fi
        # System profile (darwin-rebuild / nixos-rebuild).
        sudo nix-env -p /nix/var/nix/profiles/system --delete-generations "+$keep" 2>/dev/null || true
        # Reclaim space from the now-unreferenced paths.
        nix-collect-garbage
        sudo nix-collect-garbage
    else
        echo "==> Purging ALL old generations..."
        nix-collect-garbage -d
        sudo nix-collect-garbage -d
    fi
    echo "==> Done."
}

# Resolves the flake directory using the following priority:
# 1. FLAKE_DIR env var (manual override).
# 2. ~/.config/shell/flake-dir (cached from a previous successful run).
# 3. Symlink tracing (fallback for non home-manager managed setups).
_resolve_flake_dir() {
    if [[ -n "${FLAKE_DIR:-}" ]]; then
        echo "$FLAKE_DIR"
        return
    fi
    # Check for cached flake-dir from a previous successful run.
    if [[ -f ~/.config/shell/flake-dir ]]; then
        local cached
        cached="$(cat ~/.config/shell/flake-dir)"
        # Validate the cached path is a real repo, not a Nix store copy.
        if [[ -f "$cached/flake.nix" && "$cached" != /nix/store/* ]]; then
            echo "$cached"
            return
        fi
    fi
    # Fallback: trace the shell RC symlink back to the repo.
    local target
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        target=~/.zshrc
    else
        target=~/.bashrc
    fi
    # POSIX compatible symlink resolution.
    # This ensures cross-platform viability by avoiding a coreutils dependency
    # via homebrew on Darwin systems.
    while [[ -L "$target" ]]; do
        local link
        link="$(readlink "$target")"
        if [[ "$link" == /* ]]; then
            target="$link"
        else
            target="$(dirname "$target")/$link"
        fi
    done
    # $target now points to the real RC file inside the repo (e.g: <repo>/dotfiles/shell/.zshrc).
    # Resolve the path and walk up the directory tree until we hit the repo's root.
    (cd "$(dirname "$target")/../.." && pwd)
}

flake() {
    local flake_dir
    flake_dir="$(_resolve_flake_dir)"
    if [[ ! -f "$flake_dir/flake.nix" ]]; then
        echo "Error: Could not locate flake.nix (resolved to: $flake_dir)"
        echo "Tip: run your first build manually from the repo directory:"
        echo "  cd /path/to/your/flake && git add . && home-manager switch --flake ."
        echo "Or set FLAKE_DIR to the path of your flake repo."
        return 1
    fi
    # Cache the resolved path for future runs.
    mkdir -p ~/.config/shell
    echo "$flake_dir" > ~/.config/shell/flake-dir
    # Detect which RC file to re-source after home builds.
    local rc_file
    if [[ -n "${ZSH_VERSION:-}" ]]; then
        rc_file=~/.zshrc
    else
        rc_file=~/.bashrc
    fi
    case "$1" in
        build)
            case "$2" in
                home) git -C "$flake_dir" add . && home-manager switch --flake "$flake_dir" && source "$rc_file" ;;
                system)
                    case "$(uname)" in
                        Darwin) git -C "$flake_dir" add . && sudo darwin-rebuild switch --flake "$flake_dir" ;;
                        Linux) git -C "$flake_dir" add . && sudo nixos-rebuild switch --flake "$flake_dir" ;;
                        *) echo "Unsupported OS: $(uname)" ;;
                    esac ;;
                update)
                    git -C "$flake_dir" add . || return 1
                    ( cd "$flake_dir" && nix flake update ) || return 1
                    case "$(uname)" in
                        Darwin) sudo darwin-rebuild switch --flake "$flake_dir" || return 1 ;;
                        Linux) sudo nixos-rebuild switch --flake "$flake_dir" || return 1 ;;
                        *) echo "Unsupported OS: $(uname)"; return 1 ;;
                    esac
                    home-manager switch --flake "$flake_dir" || return 1
                    source "$rc_file" ;;
                *) echo "Usage: flake build {home|system|update}" ;;
            esac ;;
        *)
            echo "Usage:"
            echo "  flake build {home|system|update}" ;;
    esac
}
