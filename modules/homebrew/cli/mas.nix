{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.mas.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.brews = [ "mas" ];
    };
}
