{ lib, hostConfig, myLib, platform, ... }: with lib;
let
    cfg = { enable = any (u: u._1password.enable or false) (attrValues hostConfig.users); };
in
myLib.mkPlatformModule "linux" platform {
    config = mkIf cfg.enable {
        # Required for system auth.
        security.polkit.enable = true;
        # Auth via browser extension & ssh integration.
        security.polkit.extraConfig = ''
            polkit.addRule(function(action, subject) {
                if (action.id == "com.1password.1Password.authorizeSshAgent" ||
                    action.id == "com.1password.1Password.unlockDesktop") {
                    return polkit.Result.AUTH_SELF;
                }
            });
        '';
        # If using a standalone window manager (Hyprland, Sway, i3, etc.) instead
        # of a full desktop environment (GNOME/KDE), you also need to:
        # 1. Add pkgs.polkit_gnome to environment.systemPackages
        # 2. Start the polkit agent in your session:
        #    /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
    };
}
