{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.google-chrome or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [ google-chrome ];
    };
}
