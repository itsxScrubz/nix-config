{ lib, hostConfig, myLib, platform, ... }: with lib;
let
    cfg = { enable = any (u: u.macAppUtil.enable or false) (attrValues hostConfig.users); };
in
myLib.mkPlatformModule "darwin" platform {
    config = mkIf cfg.enable {
        services.mac-app-util.enable = true;
    };
}
