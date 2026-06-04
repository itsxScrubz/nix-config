{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            "steam"
        ])
    ];
}
