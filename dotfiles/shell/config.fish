# ~ History.
set -g fish_history_max 10000

# ~ Environment.
set -gx EDITOR code
set -gx VISUAL code

# ~ User-local bin (pipx, etc).
fish_add_path -gp $HOME/.local/bin

# ~ Aliases.
# ls (uses system ls — override in os-specific config if needed).
alias ls 'ls --group-directories-first --color=auto -Ah'
alias l 'ls --group-directories-first --color=auto -CF'
alias ll 'ls --group-directories-first --color=auto -lh'
alias lla 'ls --group-directories-first --color=auto -lAh'
# Navigation.
alias .. 'cd ..'
alias ... 'cd ../..'
alias cls clear
alias mkdir 'mkdir -pv'
alias grep 'grep --color=auto'
# Git.
alias gs 'git status'
alias gd 'git diff'
alias gl 'git log --oneline --graph'
alias gp 'git push -u origin main'
alias ga 'git add .'
# Nix flake.
alias fbh 'flake build home'
alias fbs 'flake build system'
alias fbu 'flake build update'

# ~ Custom Commands.
# Resolves the flake directory using the following priority:
# 1. FLAKE_DIR env var (manual override).
# 2. ~/.config/shell/flake-dir (cached from a previous successful run).
# 3. Symlink tracing (fallback for non home-manager managed setups).
function _resolve_flake_dir
    if set -q FLAKE_DIR; and test -n "$FLAKE_DIR"
        echo $FLAKE_DIR
        return
    end
    # Check for cached flake-dir from a previous successful run.
    if test -f ~/.config/shell/flake-dir
        set -l cached (cat ~/.config/shell/flake-dir)
        # Validate the cached path is a real repo, not a Nix store copy.
        if test -f "$cached/flake.nix"; and not string match -q '/nix/store/*' "$cached"
            echo $cached
            return
        end
    end
    # Fallback: trace the config.fish symlink back to the repo.
    set -l target ~/.config/fish/config.fish
    # Follow symlinks manually (POSIX-compatible, no readlink -f needed).
    while test -L "$target"
        set -l link (readlink "$target")
        if string match -q '/*' "$link"
            set target $link
        else
            set target (dirname "$target")/$link
        end
    end
    # target is now the real config.fish inside the repo (e.g: <repo>/dotfiles/shell/config.fish).
    # Walk up to the repo root.
    echo (cd (dirname "$target")/../..; and pwd)
end

function flake
    set -l flake_dir (_resolve_flake_dir)
    if not test -f "$flake_dir/flake.nix"
        echo "Error: Could not locate flake.nix (resolved to: $flake_dir)"
        echo "Tip: run your first build manually from the repo directory:"
        echo "  cd /path/to/your/flake && git add . && home-manager switch --flake ."
        echo "Or set FLAKE_DIR to the path of your flake repo."
        return 1
    end
    # Cache the resolved path for future runs.
    mkdir -p ~/.config/shell
    echo $flake_dir > ~/.config/shell/flake-dir
    switch "$argv[1]"
        case build
            switch "$argv[2]"
                case home
                    git -C "$flake_dir" add .; and home-manager switch --flake "$flake_dir"; and source ~/.config/fish/config.fish
                case system
                    switch (uname)
                        case Darwin
                            git -C "$flake_dir" add .; and sudo darwin-rebuild switch --flake "$flake_dir"
                        case Linux
                            git -C "$flake_dir" add .; and sudo nixos-rebuild switch --flake "$flake_dir"
                        case '*'
                            echo "Unsupported OS: "(uname)
                    end
                case update
                    git -C "$flake_dir" add .; or return 1
                    pushd "$flake_dir"; and nix flake update; set -l rc $status; popd; test $rc -eq 0; or return 1
                    switch (uname)
                        case Darwin
                            sudo darwin-rebuild switch --flake "$flake_dir"; or return 1
                        case Linux
                            sudo nixos-rebuild switch --flake "$flake_dir"; or return 1
                        case '*'
                            echo "Unsupported OS: "(uname); return 1
                    end
                    home-manager switch --flake "$flake_dir"; or return 1
                    source ~/.config/fish/config.fish
                case '*'
                    echo "Usage: flake build {home|system|update}"
            end
        case '*'
            echo "Usage:"
            echo "  flake build {home|system|update}"
    end
end

# ~ Source OS-specific config.
switch (uname -s)
    case Darwin
        for f in ~/.config/shell/_shared/os/darwin.*
            test -f "$f"; and source "$f"
        end
    case Linux
        for f in ~/.config/shell/_shared/os/linux.*
            test -f "$f"; and source "$f"
        end
end

# ~ Source fish-specific config.
for f in ~/.config/shell/fish/*.fish
    test -f "$f"; and source "$f"
end

# ~ Shell Integrations.
if type -q fzf; fzf --fish | source; end
if type -q zoxide; zoxide init fish | source; end
if type -q fnm; fnm env | source; end
if type -q starship; starship init fish | source; end
