{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.claude-code or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [ claude-code ];
    };
}
