{ myLib, lib, hostConfig, ... }:
let
    postgresEnabled = lib.any (u: u.postgresql.enable or false) (lib.attrValues hostConfig.users);
in {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            { name = "vscode"; pkg = "visual-studio-code"; }
            "android-studio"
            "docker-desktop"
        ])
    ];
    config = lib.mkIf postgresEnabled {
        homebrew.brews = [{
            name = "postgresql@18";
            start_service = true;
        }];
    };
}
