{ lib, hostConfig, pkgs, ... }: with lib;
let
    cfg = { enable = any (u: u.age.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ age ];
    };
}
