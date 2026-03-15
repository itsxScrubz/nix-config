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

# ~ Environment.
export EDITOR="code"
export VISUAL="code"

# ~ Aliases.
# ls
alias ls='ls --group-directories-first --color=auto -Ah'
alias l='ls --group-directories-first --color=auto -CF'
alias ll='ls --group-directories-first --color=auto -lh'
alias lla='ls --group-directories-first --color=auto -lAh'
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

# ~ Plugins.
command -v fzf &>/dev/null && eval "$(fzf --bash)"

# ~ Source.
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"
