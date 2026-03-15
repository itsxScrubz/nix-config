{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.expressvpn or { enable = false; };
in {
    config = mkIf (cfg.enable && pkgs.stdenv.isLinux) {
        home.packages = with pkgs; [ expressvpn ];
    };
}
