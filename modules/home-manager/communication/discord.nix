{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.discord or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [ discord ];
    };
}
