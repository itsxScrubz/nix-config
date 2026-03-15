{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.alt-tab.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "alt-tab" ];
    };
}
