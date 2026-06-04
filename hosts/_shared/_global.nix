{ hostConfig, pkgs, ... }:
{
    system.stateVersion = hostConfig.stateVersion.system;
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
        experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
        # Dedupe store paths at build time so we don't need periodic `nix store optimise` runs.
        # NOTE: On darwin this setting is inert because `nix.enable = false` in darwin.nix
        # (we use Determinate Nix, which manages its own nix-daemon and /etc/nix/nix.conf).
        # To enable auto-optimise on darwin, add `auto-optimise-store = true` to /etc/nix/nix.conf
        # manually, or flip `nix.enable = true` in darwin.nix (may conflict with Determinate).
        auto-optimise-store = pkgs.stdenv.isLinux;
        trusted-users = [ "root" ] ++ builtins.attrNames hostConfig.users;
    };
    time.timeZone = hostConfig.timezone;
}
