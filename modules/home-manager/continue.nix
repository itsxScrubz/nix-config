# ─── Continue VSCode extension — unified profile (templated per host) ────────
# Renders dotfiles/continue/configs/default.yaml with @APIBASE@ substituted
# per-host, symlinked directly as ~/.continue/config.yaml. Continue exposes
# all 4 chat-role models (Chat, Chat Smart, Coding Light, Coding Heavy) plus
# autocomplete + embed; user picks via Continue's model dropdown.
#
# The `ai` command manages Ollama load/unload state only — it does NOT swap
# this profile. See dotfiles/shell/_shared/ai.sh.
#
# User config (host-specific):
#   continue = {
#       enable = true;
#       mode = "server";             # mini only — apiBase = localhost
#   };
#   continue = {
#       enable = true;
#       mode = "client";             # clients   — apiBase = http://mini.local:11434
#       serverHost = "mini.local";   # optional override (defaults to mini.local)
#   };
#
# `mini.local` resolves via mDNS — macOS (mini) broadcasts via Bonjour,
# linux clients need avahi + nssmdns4 (wired declaratively in
# hosts/_shared/linux.nix). mDNS is link-local only; for off-LAN roaming
# prefer the Tailscale FQDN `ai.tail95c8d0.ts.net` (HTTPS on :11435).
{ lib, pkgs, userConfig, self, ... }: with lib;
let
    cfg = userConfig.continue or { enable = false; };
    mode = cfg.mode or "client";
    serverHost = cfg.serverHost or "mini.local";
    apiBase =
        if mode == "server"
        then "http://localhost:11434"
        else "http://${serverHost}:11434";

    rendered = pkgs.writeText "continue-config.yaml" (
        builtins.replaceStrings
            [ "@APIBASE@" ]
            [ apiBase ]
            (builtins.readFile "${self}/dotfiles/continue/configs/default.yaml")
    );
in {
    config = mkIf cfg.enable {
        home.file.".continue/config.yaml".source = rendered;
    };
}
