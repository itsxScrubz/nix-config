{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.vscode.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "visual-studio-code" ];
    };
}
