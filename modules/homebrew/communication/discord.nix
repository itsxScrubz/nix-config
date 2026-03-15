{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.discord.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "discord" ];
    };
}
