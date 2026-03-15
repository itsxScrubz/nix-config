{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.flameshot or { enable = false; };
in {
    config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
        home.packages = with pkgs; [ flameshot ];
    };
}
