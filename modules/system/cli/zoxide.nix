{ lib, hostConfig, pkgs, ... }: with lib;
let
    cfg = { enable = any (u: u.zoxide.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ zoxide ];
    };
}
