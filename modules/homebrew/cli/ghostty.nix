{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.ghostty.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "ghostty" ];
    };
}
