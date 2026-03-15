{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            "discord"
        ])
    ];
}
