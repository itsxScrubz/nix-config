{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.flameshot.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "flameshot" ];
        launchd.user.agents.flameshot = {
            command = "/Applications/flameshot.app/Contents/MacOS/flameshot";
            serviceConfig = {
                KeepAlive = true;
                RunAtLoad = true;
            };
        };
    };
}
