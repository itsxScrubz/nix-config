{
    hostName = "mini";
    primaryUser = "scrubz";
    timezone = "Asia/Taipei";
    users = {
        scrubz = (import ../../users/scrubz.nix) // {
            continue = { enable = true; mode = "server"; };
        };
        # chloe = import ../../users/chloe.nix;
    };
    stateVersion = {
        system = 6;
        home-manager = "25.11";
    };
    dock = {
        autohide = false;
        show-recents = false;
        static-only = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 26;
        mineffect = "scale";
    };
}
