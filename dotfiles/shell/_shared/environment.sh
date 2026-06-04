# ~ Environment.
export EDITOR="code"
export VISUAL="code"

# ~ User-local bin (pipx, etc).
case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
