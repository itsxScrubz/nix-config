# ─── Ollama launchd agent (mini only) ───────────────────────────────────────
# Replaces the brew-managed `homebrew.mxcl.ollama` launchd plist. Brew's plist
# regenerates on every `brew services restart` from the formula template,
# silently wiping any hand-added env vars — specifically OLLAMA_HOST, which
# must be `0.0.0.0:11434` so Ollama accepts requests from the Tailscale serve
# HTTPS reverse proxy at `ai.tail95c8d0.ts.net:11435` (its host-header check
# rejects dotted FQDNs by default and returns 403).
#
# By managing the plist declaratively via nix-darwin, all three env vars are
# reproducible on re-provision and brew interactions can't clobber them.
#
# The ollama binary comes from the official **cask** (`ollama-app`), not the
# homebrew formula — the formula's 0.30.x build never compiles the llama.cpp
# `llama-server` runner, so GGUF models fail with "llama-server binary not
# found". The cask bundles prebuilt runners inside Ollama.app; we run its
# binary headless via this agent and never open the GUI app (opening it would
# start a second server and collide on port 11434). We own the launchd agent,
# not the package. Binary: `/Applications/Ollama.app/Contents/Resources/ollama`.
#
# ── Migration steps (one-time, after first `fbs` with this module) ──
#   1. brew services stop ollama
#        Tears down the brew-managed `homebrew.mxcl.ollama` agent.
#   2. rm ~/Library/LaunchAgents/homebrew.mxcl.ollama.plist
#        Optional cleanup — the old plist file.  nix-darwin's agent lives at
#        `~/Library/LaunchAgents/org.nixos.ollama.plist`, so they don't
#        collide, but leaving the brew plist around invites confusion.
#   3. fbs
#        nix-darwin writes `org.nixos.ollama.plist` and bootstraps it.
#
# ── Verification after migration ──
#   launchctl list | grep ollama
#     → should show `org.nixos.ollama`, NOT `homebrew.mxcl.ollama`
#   ps eww -p $(pgrep -f 'ollama serve') | tr ' ' '\n' | grep ^OLLAMA_
#     → should show all three: OLLAMA_FLASH_ATTENTION, OLLAMA_KV_CACHE_TYPE,
#       OLLAMA_HOST=0.0.0.0:11434
#   curl -s -o /dev/null -w '%{http_code}\n' \
#     -H 'Host: ai.tail95c8d0.ts.net:11435' http://localhost:11434/api/tags
#     → 200 (proves OLLAMA_HOST=0.0.0.0 made the host-check permissive)
#
# ── Don't run this ever again ──
#   brew services start ollama
#   brew services restart ollama
#     Would re-create the brew plist and fight this one (identical bind port
#     11434 → second process fails to start).  If you do run it by accident,
#     `brew services stop ollama` and you're back to nix-darwin's agent.
{ ... }:
{
    launchd.user.agents.ollama = {
        serviceConfig = {
            ProgramArguments = [
                "/Applications/Ollama.app/Contents/Resources/ollama"
                "serve"
            ];
            KeepAlive = true;
            RunAtLoad = true;
            WorkingDirectory = "/opt/homebrew/var";
            StandardOutPath = "/opt/homebrew/var/log/ollama.log";
            StandardErrorPath = "/opt/homebrew/var/log/ollama.log";
            # Match brew's session-type list so the agent runs in all contexts
            # (including SSH / remote tailnet access, not just the user's Aqua
            # GUI session). Without this, non-Aqua sessions can't hit Ollama.
            LimitLoadToSessionType = [
                "Aqua"
                "Background"
                "LoginWindow"
                "StandardIO"
                "System"
            ];
            EnvironmentVariables = {
                OLLAMA_FLASH_ATTENTION = "1";
                OLLAMA_KV_CACHE_TYPE = "q8_0";
                # OLLAMA_HOST=0.0.0.0:11434 — binds to all interfaces AND
                # makes Ollama's host-header allowlist permissive.  Required
                # for Tailscale serve HTTPS (`ai.tail95c8d0.ts.net:11435`)
                # and any LAN client hitting `http://mini.local:11434`
                # directly (e.g., laptop Continue via mDNS).
                OLLAMA_HOST = "0.0.0.0:11434";
                # 4 slots so a transient "both chats + AC + embed" state can
                # exist briefly before the ai-boot watcher evicts the non-
                # chosen chat. With MAX=3, Ollama LRU can evict AC/embed
                # instead of the wrong chat — undesirable.
                OLLAMA_MAX_LOADED_MODELS = "4";
            };
        };
    };
}
