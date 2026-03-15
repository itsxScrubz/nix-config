{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.coreutils.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.brews = [ "coreutils" ];
    };
}
