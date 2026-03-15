{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig._1password or { enable = false; };
in {
    config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
        home.packages = with pkgs; [
            _1password-gui
            _1password-cli
        ];
    };
}
