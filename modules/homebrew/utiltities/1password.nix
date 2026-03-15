{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u._1password.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "1password" ];
    };
}
