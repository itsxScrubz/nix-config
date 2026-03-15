{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.zsh or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [
            fzf
            zsh-autosuggestions
            zsh-fast-syntax-highlighting
        ];
        home.file.".zsh_plugins.zsh".text = ''
            source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
            source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
        '';
    };
}
