{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.firacode-nerd-font or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            nerd-fonts.fira-code
        ];
    };
}
