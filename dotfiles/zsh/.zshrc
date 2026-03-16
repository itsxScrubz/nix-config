autoload -Uz compinit && compinit

# ~ Completion
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

# ~ Environment.
export EDITOR="code"
export VISUAL="code"

# ~ Aliases.
# ls
alias ls='gls --group-directories-first --color=auto -Ah'
alias l='gls --group-directories-first --color=auto -CF'
alias ll='gls --group-directories-first --color=auto -lh'
alias lla='gls --group-directories-first --color=auto -lAh'
#
alias ..="cd .."
alias ...="cd ../.."
alias cls="clear"
alias mkdir="mkdir -pv"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
# git
alias gs="git status"
alias gd="git diff"
alias gl="git log --oneline --graph"
alias gp="git push -u origin main"
alias ga="git add ."
# Nix flake.
alias fbh="flake build home"
alias fbs="flake build system"

# Keybinds.
if [[ "$(uname)" == "Darwin" ]]; then
    bindkey '\e[3~' delete-char
fi

# ~ Custom Commands.
flake() {
    case "$1" in
        build)
            case "$2" in
                home) git -C ~/Projects/nix-config add . && home-manager switch --flake ~/Projects/nix-config && source ~/.zshrc ;;
                system)
                    case "$(uname)" in
                        Darwin) git -C ~/Projects/nix-config add . && sudo darwin-rebuild switch --flake ~/Projects/nix-config ;;
                        Linux) git -C ~/Projects/nix-config add . && sudo nixos-rebuild switch --flake ~/Projects/nix-config ;;
                        *) echo "Unsupported OS: $(uname)" ;;
                    esac ;;
                *) echo "Usage: flake build {home|system}" ;;
            esac ;;
        *)
            echo "Usage:"
            echo "  flake build {home|system}" ;;
    esac
}

# ~ Plugins.
(( $+commands[fzf] )) && source <(fzf --zsh)
[[ -f $HOME/.zsh_plugins.zsh ]] && source $HOME/.zsh_plugins.zsh
(( $+commands[zoxide] )) && source <(zoxide init zsh)
(( $+commands[starship] )) && eval "$(starship init zsh)"
