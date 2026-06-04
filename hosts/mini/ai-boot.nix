# ─── ai-boot launchd user agent (mini only) ──────────────────────────────────
# Continuous Ollama state watcher. KeepAlive=true means launchd respawns it if
# it ever exits. Internally it loops on a 2s tick enforcing:
#   - chat mutex (only 1 of {7B, Smart} loaded)
#   - AC + embed perma-resident
#   - Smart fallback when no chat loaded
#   - no-op when Heavy coder is active
#
# ThrottleInterval prevents launchd from thrashing if the daemon crashes fast.
#
# Script source at ai-boot.sh; embedded via pkgs.writeShellScript at build time.
{ pkgs, ... }:
let
    ai-boot = pkgs.writeShellScript "ai-boot" (builtins.readFile ./ai-boot.sh);
in {
    launchd.user.agents.ai-boot = {
        command = "${ai-boot}";
        serviceConfig = {
            RunAtLoad = true;
            KeepAlive = true;
            ThrottleInterval = 10;
            StandardOutPath = "/tmp/ai-boot.log";
            StandardErrorPath = "/tmp/ai-boot.log";
        };
    };
}
