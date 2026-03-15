{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.ghostty or { enable = false; };
in {
    config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
        home.packages = [ pkgs.ghostty ];
    };
}
