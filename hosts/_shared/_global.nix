{ hostConfig, pkgs, ... }:
{
    system.stateVersion = hostConfig.stateVersion.system;
    nixpkgs.config.allowUnfree = true;
    nix.settings = {
        experimental-features = [ "nix-command" "flakes" "ca-derivations" ];
        auto-optimise-store = pkgs.stdenv.isLinux;
        trusted-users = [ "root" ] ++ builtins.attrNames hostConfig.users;
    };
    time.timeZone = hostConfig.timezone;
}
