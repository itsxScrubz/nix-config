autoload -Uz compinit && compinit

# ~ Completion.
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ~ History.
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ~ Directory navigation.
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# ~ Globbing.
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB

# ~ Keybinds.
if [[ "$(uname)" == "Darwin" ]]; then
    bindkey '\e[3~' delete-char
fi

# ~ Source shared config.
for f in ~/.config/shell/_shared/*.sh; do [[ -f "$f" && "$(basename "$f")" != "nix.sh" ]] && source "$f"; done
# ~ Source Nix-specific config (only if Nix is installed).
command -v nix &>/dev/null && [[ -f ~/.config/shell/_shared/nix.sh ]] && source ~/.config/shell/_shared/nix.sh

# ~ Source OS-specific config.
case "$(uname -s)" in
    Darwin)       for f in ~/.config/shell/_shared/os/darwin.*; do [[ -f "$f" ]] && source "$f"; done ;;
    Linux)        for f in ~/.config/shell/_shared/os/linux.*; do [[ -f "$f" ]] && source "$f"; done ;;
    MINGW*|MSYS*) for f in ~/.config/shell/_shared/os/windows.*; do [[ -f "$f" ]] && source "$f"; done ;;
esac

# ~ Source zsh-specific config.
for f in ~/.config/shell/zsh/*.zsh; do [[ -f "$f" ]] && source "$f"; done

# ~ Shell Integrations.
(( $+commands[fzf] )) && source <(fzf --zsh)
(( $+commands[zoxide] )) && source <(zoxide init zsh)
(( $+commands[fnm] )) && eval "$(fnm env)"
(( $+commands[starship] )) && eval "$(starship init zsh)"
