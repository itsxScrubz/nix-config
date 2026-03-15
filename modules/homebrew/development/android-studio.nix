{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.android-studio.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "android-studio" ];
    };
}
