{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.swift-shift.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "swift-shift" ];
    };
}
