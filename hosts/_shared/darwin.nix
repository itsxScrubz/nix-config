{ lib, hostConfig, ... }: with lib;
let
    primaryUser = hostConfig.primaryUser;
in {
    imports = [ ./_global.nix ];
    nix.enable = false;
    system.primaryUser = primaryUser;
    system.defaults.dock = hostConfig.dock or {};
    system.defaults.finder = hostConfig.users.${primaryUser}.finder or {};
    system.defaults.CustomUserPreferences.NSGlobalDomain =
        optionalAttrs
            (hostConfig.users.${primaryUser}.desktop.titleBarDoubleClick or null != null)
            { AppleActionOnDoubleClick = hostConfig.users.${primaryUser}.desktop.titleBarDoubleClick; };
    homebrew = {
        enable = true;
        taps = [ "homebrew/core" "homebrew/cask" "homebrew/bundle" ];
        onActivation.autoUpdate = true;
        onActivation.cleanup = "zap";
        masApps = hostConfig.users.${primaryUser}.masApps or {};
    };
}
