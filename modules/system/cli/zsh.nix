{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.zsh.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable  {
        programs.zsh.enable = true;
    };
}
