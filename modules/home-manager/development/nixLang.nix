{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.nixLang or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [ nixd nil ];
    };
}
