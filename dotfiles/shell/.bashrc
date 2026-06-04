# ~ History.
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=10000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# ~ Directory navigation.
shopt -s autocd
shopt -s cdspell

# ~ Globbing.
shopt -s nocaseglob
shopt -s globstar

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

# ~ Source bash-specific config.
for f in ~/.config/shell/bash/*.bash; do [[ -f "$f" ]] && source "$f"; done

# ~ Shell Integrations.
command -v fzf &>/dev/null && eval "$(fzf --bash)"
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
command -v fnm &>/dev/null && eval "$(fnm env)"
command -v starship &>/dev/null && eval "$(starship init bash)"
