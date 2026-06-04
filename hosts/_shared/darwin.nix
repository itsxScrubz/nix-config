{ lib, pkgs, hostConfig, ... }: with lib;
let
    primaryUser = hostConfig.primaryUser;
in {
    imports = [ ./_global.nix ];
    nix.enable = false;
    # Automatic nix garbage collection — weekly Sunday 3am, drops generations older than 30 days.
    # Implemented as a launchd daemon because `nix.enable = false` (Determinate Nix) disables the
    # standard nix-darwin `nix.gc` module path. Uses pkgs.nix from nixpkgs for the binary since
    # Determinate's daemon speaks the same wire protocol.
    launchd.daemons.nix-gc = {
        command = "${pkgs.nix}/bin/nix-collect-garbage --delete-older-than 30d";
        serviceConfig = {
            StartCalendarInterval = [{
                Weekday = 0;
                Hour = 3;
                Minute = 0;
            }];
            RunAtLoad = false;
            StandardOutPath = "/var/log/nix-gc.log";
            StandardErrorPath = "/var/log/nix-gc.log";
        };
    };
    system.primaryUser = primaryUser;
    system.defaults.dock = hostConfig.dock or {};
    system.defaults.finder = hostConfig.users.${primaryUser}.finder or {};
    system.defaults.CustomUserPreferences.NSGlobalDomain =
        optionalAttrs
            (hostConfig.users.${primaryUser}.desktop.titleBarDoubleClick or null != null)
            { AppleActionOnDoubleClick = hostConfig.users.${primaryUser}.desktop.titleBarDoubleClick; };
    homebrew = {
        enable = true;
        # ~ homebrew/bundle was deprecated and migrated into brew core; tapping it now
        # ~ errors. homebrew/core and homebrew/cask auto-tap on first install.
        taps = [
            "homebrew/core"
            "homebrew/cask"
        ];
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
        onActivation.cleanup = "zap";
        # ~ Newer `brew bundle install --cleanup` refuses in non-interactive shells without
        # ~ `--force`, `--force-cleanup`, or `$HOMEBREW_ASK`. Auto-confirm during activation.
        onActivation.extraFlags = [ "--force" ];
        masApps = hostConfig.users.${primaryUser}.masApps or {};
    };
}
