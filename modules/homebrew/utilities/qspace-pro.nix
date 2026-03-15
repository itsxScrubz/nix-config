{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.qspace-pro.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "qspace-pro" ];
    };
}
