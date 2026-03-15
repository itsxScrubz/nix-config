{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.zsh or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            zsh-autosuggestions
            zsh-syntax-highlighting
        ];
    };
}
