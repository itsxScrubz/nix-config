{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.logitech-g-hub.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "logitech-g-hub" ];
    };
}
