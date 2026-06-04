{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            "vivaldi"
        ])
    ];
}
