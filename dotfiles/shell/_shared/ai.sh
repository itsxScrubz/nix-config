# -----------------------------------------------------------------------------
#  ai — Local AI Control
# -----------------------------------------------------------------------------
#  Sourced by ~/.zshrc via the _shared/*.sh glob loop. Exposes a single `ai`
#  shell function; everything below lives inside a subshell — ai() ( ... ) —
#  so helpers, color vars, and `set -u` never leak into the interactive shell.
#
#  Scope: chat-model lifecycle only. Continue picks coders via its own model
#  dropdown (default.yaml lists all 4 chat-role models). This command exists
#  so you can re-warm a chat model from the terminal without opening VSCode.
#
#  Usage:
#    ai | ai status        — loaded models, inactive models, system info
#    ai help | ai --help   — usage screen
#    ai set chat           — load Chat (7B),  evict coders + Chat Smart
#    ai set chat smart     — load Chat Smart (14B), evict coders + 7B
#    ai swap chat          — toggle 7B ↔ Smart
#
#  `ai set *` / `ai swap *` require Ollama at $OLLAMA_URL.
# -----------------------------------------------------------------------------
ai() (
set -u

# ─── Color Palette (truecolor RGB) ───────────────────────────────────────────
RESET=$'\e[0m'
BOLD=$'\e[1m'
DIM=$'\e[2m'
ITALIC=$'\e[3m'

# Brand / accent
PINK=$'\e[38;2;255;115;189m'
CYAN=$'\e[38;2;125;211;252m'
BLUE=$'\e[38;2;96;165;250m'
PURPLE=$'\e[38;2;196;181;253m'

# Status
GREEN=$'\e[38;2;134;239;172m'
YELLOW=$'\e[38;2;253;224;71m'
ORANGE=$'\e[38;2;251;146;60m'
RED=$'\e[38;2;248;113;113m'

# Text
WHITE=$'\e[38;2;248;250;252m'
LIGHT=$'\e[38;2;203;213;225m'
GRAY=$'\e[38;2;148;163;184m'
DARK=$'\e[38;2;100;116;139m'

# ─── Config ──────────────────────────────────────────────────────────────────
OLLAMA_URL="http://localhost:11434"
LIGHT_CODER="qwen2.5-coder:14b"
HEAVY_CODER="qwen3-coder:30b"
CHAT_MODEL="huihui_ai/qwen2.5-1m-abliterated:7b"
CHAT_SMART_MODEL="huihui_ai/qwen2.5-1m-abliterated:14b"
AUTOCOMPLETE_MODEL="qwen2.5-coder:1.5b-base"
EMBED_MODEL="nomic-embed-text:latest"
CHAT_KEEP_ALIVE="${AI_KEEP_ALIVE:--1}"
BOX_WIDTH=66

# ─── Box Drawing Helpers ─────────────────────────────────────────────────────
hr() {
    local color="${1:-$DARK}"
    local width="${2:-$BOX_WIDTH}"
    local char="${3:-─}"
    local line=""
    local i
    for ((i=0; i<width; i++)); do line+="$char"; done
    printf "%s%s%s\n" "$color" "$line" "$RESET"
}

banner() {
    local title="$1"
    local accent="${2:-$PINK}"
    local inner=$((BOX_WIDTH - 2))
    printf "%s╭" "$accent"
    local i
    for ((i=0; i<inner; i++)); do printf "─"; done
    printf "╮%s\n" "$RESET"

    local plain_title="$title"
    local title_len=${#plain_title}
    local pad=$((inner - title_len - 3))
    printf "%s│%s  %s%s%s" "$accent" "$RESET" "$BOLD$WHITE" "$title" "$RESET"
    printf "%*s" "$pad" ""
    printf "%s│%s\n" "$accent" "$RESET"

    printf "%s╰" "$accent"
    for ((i=0; i<inner; i++)); do printf "─"; done
    printf "╯%s\n" "$RESET"
}

section() {
    local label="$1"
    local icon="${2:-}"
    printf "\n\n  %s%s%s %s%s%s\n" "$CYAN" "$icon" "$RESET" "$BOLD$CYAN" "$label" "$RESET"
    printf "  %s" "$DARK"
    local i
    for ((i=0; i<40; i++)); do printf "─"; done
    printf "%s\n" "$RESET"
}

kv() {
    local key="$1"
    local value="$2"
    local value_color="${3:-$WHITE}"
    printf "  %s%-14s%s %s%s%s\n" "$GRAY" "$key" "$RESET" "$value_color" "$value" "$RESET"
}

# ─── Data Helpers ────────────────────────────────────────────────────────────
fetch_loaded_models() {
    curl -s --max-time 3 "$OLLAMA_URL/api/ps" 2>/dev/null
}

get_loaded_names() {
    fetch_loaded_models | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(' '.join(m.get('name','') for m in d.get('models',[])))
except Exception:
    pass
" 2>/dev/null
}

bytes_to_gb() {
    python3 -c "import sys; print(f'{int(sys.argv[1])/1073741824:.1f}')" "$1"
}

get_sys_ram_gb() {
    local bytes
    bytes=$(sysctl -n hw.memsize 2>/dev/null || echo "0")
    bytes_to_gb "$bytes"
}

get_cpu_info() {
    sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown"
}

get_cpu_cores() {
    sysctl -n hw.ncpu 2>/dev/null || echo "?"
}

get_hostname() {
    scutil --get ComputerName 2>/dev/null || hostname
}

get_llm_disk() {
    curl -s --max-time 3 "$OLLAMA_URL/api/tags" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    models = d.get('models', [])
    total = sum(m.get('size', 0) for m in models)
    print(f'{total/1073741824:.1f} GB  ({len(models)} models)')
except Exception:
    print('unknown')
" 2>/dev/null
}

# ─── State-change helpers ────────────────────────────────────────────────────
ollama_up() {
    curl -sf --max-time 2 "$OLLAMA_URL/api/tags" >/dev/null 2>&1
}

ollama_load() {
    local model="$1"
    local keep="${2:-$CHAT_KEEP_ALIVE}"
    local keep_json
    if [[ "$keep" =~ ^-?[0-9]+$ ]]; then keep_json="$keep"; else keep_json="\"$keep\""; fi
    curl -sf -o /dev/null --max-time 180 -X POST "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$model\",\"prompt\":\"\",\"keep_alive\":$keep_json,\"stream\":false}"
}

ollama_unload() {
    local model="$1"
    curl -sf -o /dev/null --max-time 15 -X POST "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$model\",\"prompt\":\"\",\"keep_alive\":0,\"stream\":false}"
}

# Embedding models need /api/embed, not /api/generate.
ollama_load_embed() {
    local model="$1"
    local keep="${2:-$CHAT_KEEP_ALIVE}"
    local keep_json
    if [[ "$keep" =~ ^-?[0-9]+$ ]]; then keep_json="$keep"; else keep_json="\"$keep\""; fi
    curl -sf -o /dev/null --max-time 60 -X POST "$OLLAMA_URL/api/embed" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$model\",\"input\":\"warmup\",\"keep_alive\":$keep_json}"
}

# Run a labeled step with ✓/✗ feedback. Args after label are the command.
run_step() {
    local label="$1"; shift
    printf "    %s→%s %s%s...%s " "$DIM$GRAY" "$RESET" "$LIGHT" "$label" "$RESET"
    if "$@" >/dev/null 2>&1; then
        printf "%s✓%s\n" "$GREEN" "$RESET"
        return 0
    else
        printf "%s✗%s\n" "$RED" "$RESET"
        return 1
    fi
}

set_header() {
    local icon="$1"
    local color="$2"
    local title="$3"
    printf "\n  %s%s%s %s%s%s\n" "$color" "$icon" "$RESET" "$BOLD$color" "$title" "$RESET"
}

require_ollama() {
    if ! ollama_up; then
        printf "\n  %s✗%s %sOllama is not reachable at %s%s%s\n" \
            "$RED" "$RESET" "$BOLD$RED" "$CYAN" "$OLLAMA_URL" "$RESET"
        printf "    %sStart it first: %s%sbrew services start ollama%s\n\n" \
            "$LIGHT" "$BOLD" "$CYAN" "$RESET"
        return 1
    fi
}

# ─── Commands ────────────────────────────────────────────────────────────────
cmd_status() {
    printf "\n"
    banner "🧠  Local AI Status"
    printf "\n"
    printf "  %sFor help use:%s %s%sai help%s   %s|%s   %s%sai --help%s\n" \
        "$DIM$LIGHT" "$RESET" "$BOLD" "$PINK" "$RESET" \
        "$DARK" "$RESET" "$BOLD" "$PINK" "$RESET"

    # ── Loaded Models ────────────────────────────
    section "LOADED MODELS" "⬢"

    local json
    json=$(fetch_loaded_models)
    if [[ -z "$json" ]]; then
        printf "  %s%s(Ollama unreachable)%s\n" "$ITALIC" "$RED" "$RESET"
    else
        local count
        count=$(echo "$json" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('models',[])))" 2>/dev/null || echo 0)
        if [[ "$count" == "0" ]]; then
            printf "  %s%sno models currently loaded%s\n" "$ITALIC" "$DIM" "$RESET"
        else
            OLLAMA_PS_JSON="$json" SYS_RAM_GB="$(get_sys_ram_gb)" python3 <<'PYEOF'
import os, json, re, datetime

PINK   = '\x1b[38;2;255;115;189m'
YELLOW = '\x1b[38;2;253;224;71m'
ORANGE = '\x1b[38;2;251;146;60m'
RED    = '\x1b[38;2;248;113;113m'
GREEN  = '\x1b[38;2;134;239;172m'
CYAN   = '\x1b[38;2;125;211;252m'
WHITE  = '\x1b[38;2;248;250;252m'
GRAY   = '\x1b[38;2;148;163;184m'
DARK   = '\x1b[38;2;100;116;139m'
DIM    = '\x1b[2m'
BOLD   = '\x1b[1m'
RESET  = '\x1b[0m'

NAME_W = 40
ANSI_RE = re.compile(r'\x1b\[[0-9;]*m')

def visible_len(s: str) -> int:
    return len(ANSI_RE.sub('', s))

MODEL_META = {
    'huihui_ai/qwen2.5-1m-abliterated:7b':  ('Chat',                  GREEN,  True),
    'huihui_ai/qwen2.5-1m-abliterated:14b': ('Chat — Smart',          GREEN,  True),
    'qwen3-coder:30b':                   ('Coding — Heavy',         PINK,   False),
    'qwen2.5-coder:14b':                 ('Coding — Light',         YELLOW, False),
    'qwen2.5-coder:1.5b-base':           ('Coding — Auto Complete', CYAN,   False),
    'nomic-embed-text:latest':           ('Coding — Embeddings',    CYAN,   False),
}

try:
    d = json.loads(os.environ.get('OLLAMA_PS_JSON', '{}'))
except Exception:
    d = {}
models = d.get('models', [])
total = 0.0

_now = datetime.datetime.now(datetime.timezone.utc)

def fmt_ttl(expires_at_str):
    if not expires_at_str:
        return ''
    try:
        exp = datetime.datetime.fromisoformat(expires_at_str)
    except Exception:
        return ''
    if exp.tzinfo is None:
        exp = exp.replace(tzinfo=datetime.timezone.utc)
    secs = int((exp - _now).total_seconds())
    if secs <= 0:
        return f'{DARK}·{RESET} {RED}expiring{RESET}'
    # keep_alive=-1 → Ollama reports a year-out expiry; show as "perma"
    if secs > 86400 * 30:
        return f'{DARK}·{RESET} {GREEN}perma{RESET}'
    if secs >= 3600:
        label = f'{secs//3600}h {(secs%3600)//60:02d}m'
    elif secs >= 60:
        label = f'{secs//60}m {secs%60:02d}s'
    else:
        label = f'{secs}s'
    if secs > 300:
        clr = GREEN
    elif secs > 60:
        clr = YELLOW
    else:
        clr = ORANGE
    return f'{DARK}·{RESET} {clr}{label}{RESET}'

for m in models:
    name = m.get('name', '?')
    size = m.get('size', 0) / 1073741824
    total += size
    friendly, color, uncensored = MODEL_META.get(name, (name, GRAY, False))

    label = f'{BOLD}{WHITE}{friendly}{RESET}'
    if uncensored:
        label += f' {ORANGE}[UNCENSORED]{RESET}'

    pad = ' ' * max(1, NAME_W - visible_len(label))

    ttl = fmt_ttl(m.get('expires_at', ''))
    ttl_suffix = f'  {ttl}' if ttl else ''

    print(f'  {color}●{RESET}  {label}{pad}{GRAY}{size:>5.1f} GB{RESET}{ttl_suffix}')
    if friendly != name:
        print(f'     {GRAY}{name}{RESET}')

print(f'     {DARK}' + '─' * (NAME_W + 8) + f'{RESET}')

try:
    sys_ram_gb = float(os.environ.get('SYS_RAM_GB', '24'))
except Exception:
    sys_ram_gb = 24.0
pct = (total / sys_ram_gb * 100) if sys_ram_gb > 0 else 0

if pct < 50:
    usage_color = GREEN
elif pct < 75:
    usage_color = YELLOW
elif pct < 90:
    usage_color = ORANGE
else:
    usage_color = RED

LINE_W = NAME_W + 8
left_plain  = 'RAM USAGE'
right_plain = f'{total:.1f} GB / {sys_ram_gb:.0f} GB  ·  {pct:.0f}%'
gap = max(1, LINE_W - len(left_plain) - len(right_plain))
print(
    f'     '
    f'{DIM}{BOLD}RAM USAGE{RESET}'
    f'{" " * gap}'
    f'{usage_color}{total:.1f} GB / {sys_ram_gb:.0f} GB  ·  {pct:.0f}%{RESET}'
)
PYEOF
        fi
    fi

    # ── Inactive Models ──────────────────────────
    section "INACTIVE MODELS" "○"
    local tags_json
    tags_json=$(curl -s --max-time 3 "$OLLAMA_URL/api/tags" 2>/dev/null)
    if [[ -z "$tags_json" ]]; then
        printf "  %s%s(Ollama unreachable)%s\n" "$ITALIC" "$RED" "$RESET"
    else
        OLLAMA_TAGS_JSON="$tags_json" OLLAMA_LOADED_NAMES="$(get_loaded_names)" python3 <<'PYEOF'
import os, json, re

PINK   = '\x1b[38;2;255;115;189m'
YELLOW = '\x1b[38;2;253;224;71m'
ORANGE = '\x1b[38;2;251;146;60m'
GREEN  = '\x1b[38;2;134;239;172m'
CYAN   = '\x1b[38;2;125;211;252m'
WHITE  = '\x1b[38;2;248;250;252m'
GRAY   = '\x1b[38;2;148;163;184m'
DARK   = '\x1b[38;2;100;116;139m'
DIM    = '\x1b[2m'
BOLD   = '\x1b[1m'
ITALIC = '\x1b[3m'
RESET  = '\x1b[0m'

NAME_W = 40
ANSI_RE = re.compile(r'\x1b\[[0-9;]*m')

def visible_len(s: str) -> int:
    return len(ANSI_RE.sub('', s))

MODEL_META = {
    'huihui_ai/qwen2.5-1m-abliterated:7b':  ('Chat',                  GREEN,  True),
    'huihui_ai/qwen2.5-1m-abliterated:14b': ('Chat — Smart',          GREEN,  True),
    'qwen3-coder:30b':                   ('Coding — Heavy',         PINK,   False),
    'qwen2.5-coder:14b':                 ('Coding — Light',         YELLOW, False),
    'qwen2.5-coder:1.5b-base':           ('Coding — Auto Complete', CYAN,   False),
    'nomic-embed-text:latest':           ('Coding — Embeddings',    CYAN,   False),
}

try:
    d = json.loads(os.environ.get('OLLAMA_TAGS_JSON', '{}'))
except Exception:
    d = {}

loaded_names = set(os.environ.get('OLLAMA_LOADED_NAMES', '').split())

inactive = []
for m in d.get('models', []):
    name = m.get('name', '?')
    if name in loaded_names:
        continue
    inactive.append((name, m.get('size', 0) / 1073741824))

if not inactive:
    print(f'  {ITALIC}{DIM}(all downloaded models are currently loaded){RESET}')
else:
    meta_order = list(MODEL_META.keys())
    def sort_key(item):
        n = item[0]
        if n in meta_order:
            return (0, meta_order.index(n))
        return (1, n)
    inactive.sort(key=sort_key)

    for name, size in inactive:
        friendly, color, uncensored = MODEL_META.get(name, (name, GRAY, False))

        label = f'{WHITE}{friendly}{RESET}'
        if uncensored:
            label += f' {ORANGE}[UNCENSORED]{RESET}'

        pad = ' ' * max(1, NAME_W - visible_len(label))

        print(f'  {color}○{RESET}  {label}{pad}{GRAY}{size:>5.1f} GB{RESET}')
        if friendly != name:
            print(f'     {GRAY}{name}{RESET}')
PYEOF
    fi

    # ── System ──────────────────────────────────
    section "SYSTEM" "🖥 "
    kv "Host" "$(get_hostname)" "$WHITE"
    kv "CPU" "$(get_cpu_info) · $(get_cpu_cores) cores" "$WHITE"
    kv "RAM" "$(get_sys_ram_gb) GB" "$WHITE"
    kv "LLM Storage" "$(get_llm_disk)" "$WHITE"

    printf "\n"
}

cmd_help() {
    printf "\n"
    banner "🧠  ai — Local AI Control"
    printf "\n"
    printf "  %sUSAGE%s\n" "$BOLD$PINK" "$RESET"
    printf "    %sai %s<command>%s %s[args]%s\n\n" "$WHITE" "$CYAN" "$RESET" "$DIM" "$RESET"

    printf "  %sCOMMANDS%s\n" "$BOLD$PINK" "$RESET"
    printf "    %s%-24s%s %s%s%s\n" "$CYAN" "ai" "$RESET" "$LIGHT" "Show current AI + system status" "$RESET"
    printf "    %s%-24s%s %s%s%s\n" "$CYAN" "ai status" "$RESET" "$LIGHT" "Alias for \`ai\`" "$RESET"
    printf "    %s%-24s%s %s%s%s\n" "$CYAN" "ai help / ai --help" "$RESET" "$LIGHT" "Show this help" "$RESET"
    printf "\n"

    printf "  %sChat Control%s\n" "$BOLD$PINK" "$RESET"
    printf "    %s%-24s%s %s%s%s\n" "$CYAN" "ai set chat" "$RESET" "$LIGHT" "Load Chat (7B),  evict coders + Smart" "$RESET"
    printf "    %s%-24s%s %s%s%s\n" "$CYAN" "ai set chat smart" "$RESET" "$LIGHT" "Load Chat Smart (14B), evict coders + 7B" "$RESET"
    printf "    %s%-24s%s %s%s%s\n" "$CYAN" "ai swap chat" "$RESET" "$LIGHT" "Toggle 7B ↔ Smart" "$RESET"
    printf "\n"

    printf "  %sNOTES%s\n" "$BOLD$PINK" "$RESET"
    printf "    %s•%s %sChat models load with %skeep_alive=%s%s%s %s(perma by default)%s\n" \
        "$PINK" "$RESET" "$LIGHT" "$BOLD$WHITE" "$BOLD$WHITE" "$CHAT_KEEP_ALIVE" "$RESET$LIGHT" "$DIM$GRAY" "$RESET"
    printf "    %s•%s %sContinue picks coders via its own model dropdown%s\n" \
        "$PINK" "$RESET" "$LIGHT" "$RESET"
    printf "    %s•%s %sSmart auto-loads at system start via ai-boot launchd agent%s\n" \
        "$PINK" "$RESET" "$LIGHT" "$RESET"
    printf "\n"
}

# Unload anything that isn't the target chat model or AC/embed.
evict_non_chat() {
    local target="$1"
    local loaded="$2"
    local other_chat
    if [[ "$target" == "$CHAT_MODEL" ]]; then
        other_chat="$CHAT_SMART_MODEL"
    else
        other_chat="$CHAT_MODEL"
    fi
    if echo "$loaded" | grep -q "$HEAVY_CODER"; then
        run_step "Unloading $HEAVY_CODER" ollama_unload "$HEAVY_CODER" || return 1
    fi
    if echo "$loaded" | grep -q "$LIGHT_CODER"; then
        run_step "Unloading $LIGHT_CODER" ollama_unload "$LIGHT_CODER" || return 1
    fi
    if echo "$loaded" | grep -q "$other_chat"; then
        run_step "Unloading $other_chat" ollama_unload "$other_chat" || return 1
    fi
}

load_chat_stack() {
    local target="$1"
    local label="$2"
    run_step "Loading $target (keep_alive=$CHAT_KEEP_ALIVE)" ollama_load "$target" || return 1
    run_step "Loading $AUTOCOMPLETE_MODEL" ollama_load "$AUTOCOMPLETE_MODEL" || return 1
    run_step "Loading $EMBED_MODEL" ollama_load_embed "$EMBED_MODEL" || return 1
}

cmd_set() {
    local target="${1:-}"
    local sub="${2:-}"

    if [[ -z "$target" || "$target" == "help" ]]; then
        printf "\n  %sUsage:%s %sai set chat [smart]%s\n\n" "$BOLD$YELLOW" "$RESET" "$CYAN" "$RESET"
        return 1
    fi

    case "$target" in
        chat)
            require_ollama || return 1
            local loaded
            loaded=$(get_loaded_names)

            case "$sub" in
                ""|default|7b)
                    if echo "$loaded" | grep -q "$CHAT_MODEL" \
                       && ! echo "$loaded" | grep -qE "qwen2\.5-coder:14b|qwen3-coder:30b|abliterated:14b"; then
                        printf "\n  %s💬%s %sChat (7B) already active%s\n\n" \
                            "$GREEN" "$RESET" "$BOLD$GREEN" "$RESET"
                        return 0
                    fi
                    set_header "💬" "$GREEN" "Switching to Chat (7B)"
                    evict_non_chat "$CHAT_MODEL" "$loaded" || return 1
                    load_chat_stack "$CHAT_MODEL" "Chat" || return 1
                    printf "\n"
                    ;;
                smart|14b)
                    if echo "$loaded" | grep -q "$CHAT_SMART_MODEL" \
                       && ! echo "$loaded" | grep -qE "qwen2\.5-coder:14b|qwen3-coder:30b"; then
                        printf "\n  %s💬%s %sChat Smart (14B) already active%s\n\n" \
                            "$GREEN" "$RESET" "$BOLD$GREEN" "$RESET"
                        return 0
                    fi
                    set_header "💬" "$GREEN" "Switching to Chat Smart (14B)"
                    evict_non_chat "$CHAT_SMART_MODEL" "$loaded" || return 1
                    load_chat_stack "$CHAT_SMART_MODEL" "Chat Smart" || return 1
                    printf "\n"
                    ;;
                *)
                    printf "\n  %s✗%s %sUnknown chat tier: %s%s%s\n" "$RED" "$RESET" "$BOLD$RED" "$CYAN" "$sub" "$RESET"
                    printf "    %sValid: %s%ssmart%s %s(or omit for 7B)%s\n\n" "$LIGHT" "$BOLD" "$CYAN" "$RESET" "$DIM$GRAY" "$RESET"
                    return 1
                    ;;
            esac
            ;;

        *)
            printf "\n  %s✗%s %sUnknown target: %s%s%s\n" "$RED" "$RESET" "$BOLD$RED" "$CYAN" "$target" "$RESET"
            printf "    %sValid: %s%schat%s\n\n" "$LIGHT" "$BOLD" "$CYAN" "$RESET"
            return 1
            ;;
    esac
}

cmd_swap() {
    local target="${1:-}"

    if [[ -z "$target" || "$target" == "help" ]]; then
        printf "\n  %sUsage:%s %sai swap chat%s\n\n" "$BOLD$YELLOW" "$RESET" "$CYAN" "$RESET"
        return 1
    fi

    case "$target" in
        chat)
            require_ollama || return 1
            local loaded
            loaded=$(get_loaded_names)

            if echo "$loaded" | grep -q "$CHAT_SMART_MODEL"; then
                set_header "💬 → 💬" "$GREEN" "Swap: Smart (14B) → Chat (7B)"
                evict_non_chat "$CHAT_MODEL" "$loaded" || return 1
                load_chat_stack "$CHAT_MODEL" "Chat" || return 1
                printf "\n"
            elif echo "$loaded" | grep -q "$CHAT_MODEL"; then
                set_header "💬 → 💬" "$GREEN" "Swap: Chat (7B) → Smart (14B)"
                evict_non_chat "$CHAT_SMART_MODEL" "$loaded" || return 1
                load_chat_stack "$CHAT_SMART_MODEL" "Chat Smart" || return 1
                printf "\n"
            else
                set_header "💬" "$GREEN" "No chat model loaded — loading Smart (14B)"
                evict_non_chat "$CHAT_SMART_MODEL" "$loaded" || return 1
                load_chat_stack "$CHAT_SMART_MODEL" "Chat Smart" || return 1
                printf "\n"
            fi
            ;;
        *)
            printf "\n  %s✗%s %sUnknown swap target: %s%s%s\n" "$RED" "$RESET" "$BOLD$RED" "$CYAN" "$target" "$RESET"
            printf "    %sValid: %s%schat%s\n\n" "$LIGHT" "$BOLD" "$CYAN" "$RESET"
            return 1
            ;;
    esac
}

# ─── Router ──────────────────────────────────────────────────────────────────
main() {
    local cmd="${1:-status}"
    case "$cmd" in
        status|"")          cmd_status ;;
        help|--help|-h)     cmd_help ;;
        set)                shift; cmd_set "$@" ;;
        swap)               shift; cmd_swap "$@" ;;
        *)
            printf "\n  %s✗%s %sUnknown command: %s%s%s\n" "$RED" "$RESET" "$BOLD$RED" "$CYAN" "$cmd" "$RESET"
            printf "    %sTry %s%sai help%s\n\n" "$LIGHT" "$BOLD" "$CYAN" "$RESET"
            return 1
            ;;
    esac
}

main "$@"
)
