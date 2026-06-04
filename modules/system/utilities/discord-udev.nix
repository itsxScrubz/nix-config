{ lib, hostConfig, myLib, platform, ... }: with lib;
let
    cfg = { enable = any (u: u.discord.enable or false) (attrValues hostConfig.users); };
in
myLib.mkPlatformModule "linux" platform {
    config = mkIf cfg.enable {
        services.udev.extraRules = ''
            KERNEL=="uinput", GROUP="input", MODE="0660"
        '';
    };
}
