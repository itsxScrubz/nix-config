# -----------------------------------------------------------------------------
#  ai-boot — continuous Ollama state watcher (2s tick).
# -----------------------------------------------------------------------------
#  Runs as a KeepAlive daemon. Each 2s tick:
#
#    1. Heavy coder (30B) loaded → no-op (solo on 24 GB)
#    2. Chat mutex via state-diff: if a chat just APPEARED in /api/ps since
#       last tick AND the other chat is also present → unload the other.
#       "Just appeared" = set difference between current and previous tick.
#       This flips correctly: picking 7B evicts Smart; picking Smart evicts
#       7B. Works for Continue and OWUI (both hit Ollama directly).
#    3. AC + embed perma — re-warmed every ~60s (keep_alive=-1)
#    4. Chat fallback — if NO chat loaded → warm Smart (default state)
#
#  State: /tmp/ai-boot-prev (set of loaded names, one per line)
#
#  Embedded via pkgs.writeShellScript at flake build time.
# -----------------------------------------------------------------------------
set -u

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

OLLAMA_URL="http://localhost:11434"
CHAT_MODEL="huihui_ai/qwen2.5-1m-abliterated:7b"
CHAT_SMART_MODEL="huihui_ai/qwen2.5-1m-abliterated:14b"
AUTOCOMPLETE_MODEL="qwen2.5-coder:1.5b-base"
EMBED_MODEL="nomic-embed-text:latest"
HEAVY_CODER="qwen3-coder:30b"

PREV_STATE="/tmp/ai-boot-prev"
TICK_SECS=2
WARMUP_EVERY_N_TICKS=30   # ~60s

ts()  { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '[%s] %s\n' "$(ts)" "$*"; }

wait_for_ollama() {
    local i
    for ((i=0; i<30; i++)); do
        if curl -sf --max-time 2 "$OLLAMA_URL/api/tags" >/dev/null 2>&1; then
            return 0
        fi
        sleep 2
    done
    return 1
}

# Emit each loaded model name on its own line (stable for set diff).
get_loaded_lines() {
    curl -sf --max-time 2 "$OLLAMA_URL/api/ps" 2>/dev/null | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for m in d.get('models', []):
        n = m.get('name','')
        if n:
            print(n)
except Exception:
    pass
" 2>/dev/null
}

warm_chat() {
    curl -sf -o /dev/null --max-time 180 -X POST "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$1\",\"prompt\":\"\",\"keep_alive\":-1,\"stream\":false}"
}

warm_embed() {
    curl -sf -o /dev/null --max-time 60 -X POST "$OLLAMA_URL/api/embed" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$1\",\"input\":\"warmup\",\"keep_alive\":-1}"
}

unload_chat() {
    curl -sf -o /dev/null --max-time 15 -X POST "$OLLAMA_URL/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"$1\",\"prompt\":\"\",\"keep_alive\":0,\"stream\":false}"
}

if ! wait_for_ollama; then
    log "ERROR: Ollama never came up — daemon exiting"
    exit 1
fi

log "daemon started (tick=${TICK_SECS}s)"
: > "$PREV_STATE"

tick=0
while true; do
    loaded=$(get_loaded_lines)
    prev=$(cat "$PREV_STATE" 2>/dev/null)
    # ── Rule 1: Heavy is solo ───────────────────────────────────────────────
    if echo "$loaded" | grep -qx "$HEAVY_CODER"; then
        printf '%s\n' "$loaded" > "$PREV_STATE"
        sleep "$TICK_SECS"
        tick=$((tick + 1))
        continue
    fi
    # ── Rule 2: Chat mutex via state-diff ───────────────────────────────────
    # New models this tick = loaded \ prev
    new_models=$(comm -23 <(printf '%s\n' "$loaded" | sort -u) <(printf '%s\n' "$prev" | sort -u) 2>/dev/null)
    added_7b=0
    added_14b=0
    echo "$new_models" | grep -qx "$CHAT_MODEL"       && added_7b=1
    echo "$new_models" | grep -qx "$CHAT_SMART_MODEL" && added_14b=1
    has_7b=0
    has_14b=0
    echo "$loaded" | grep -qx "$CHAT_MODEL"       && has_7b=1
    echo "$loaded" | grep -qx "$CHAT_SMART_MODEL" && has_14b=1
    if [[ $added_7b -eq 1 && $has_14b -eq 1 ]]; then
        if unload_chat "$CHAT_SMART_MODEL"; then
            log "mutex: 7B just loaded → unloaded Smart"
            has_14b=0
        else
            log "ERROR: failed to unload Smart"
        fi
    elif [[ $added_14b -eq 1 && $has_7b -eq 1 ]]; then
        if unload_chat "$CHAT_MODEL"; then
            log "mutex: Smart just loaded → unloaded 7B"
            has_7b=0
        else
            log "ERROR: failed to unload 7B"
        fi
    fi
    # Re-snapshot after any mutex action for accurate next-tick diff.
    loaded=$(get_loaded_lines)
    printf '%s\n' "$loaded" > "$PREV_STATE"
    # ── Rule 3: AC + embed perma (every ~60s) ───────────────────────────────
    if (( tick % WARMUP_EVERY_N_TICKS == 0 )); then
        warm_chat  "$AUTOCOMPLETE_MODEL" || log "ERROR: warm AC"
        warm_embed "$EMBED_MODEL"        || log "ERROR: warm embed"
    fi
    # ── Rule 4: Chat fallback — warm Smart if no chat loaded ────────────────
    if [[ $has_7b -eq 0 && $has_14b -eq 0 ]]; then
        if warm_chat "$CHAT_SMART_MODEL"; then
            log "no chat loaded — warmed Smart"
        else
            log "ERROR: failed to warm Smart"
        fi
    fi
    sleep "$TICK_SECS"
    tick=$((tick + 1))
done
