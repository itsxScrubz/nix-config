{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            "logitech-g-hub"
        ])
    ];
}
