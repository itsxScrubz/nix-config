{ lib, userConfig, ... }: with lib;
let
    cfg = userConfig.starship or { enable = false; };
in {
    config = mkIf cfg.enable {
        programs.starship = {
            enable = true;
            enableZshIntegration = true;
        };
    };
}
