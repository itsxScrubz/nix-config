{ lib, userConfig, ... }: with lib;
let
    cfg = userConfig.direnv or { enable = false; };
in {
    config = mkIf cfg.enable {
        programs.direnv = {
            enable = true;
            nix-direnv.enable = true;
            silent = true;
        };
    };
}
