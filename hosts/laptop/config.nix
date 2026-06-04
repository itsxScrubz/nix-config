{
    hostName = "laptop";
    timezone = "Asia/Taipei";
    users = {
        scrubz = (import ../../users/scrubz.nix) // {
            continue = { enable = true; mode = "client"; };
        };
        # myUser = import ../../users/<name>.nix;
    };
    stateVersion = {
        system = "25.11";
        home-manager = "25.11";
    };
}
