{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.vivaldi.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "vivaldi" ];
    };
}
