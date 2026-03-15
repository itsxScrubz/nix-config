{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            "ghostty"
        ])
        (myLib.mkHomebrewModules "brews" [
            "coreutils" "mas"
        ])
    ];
}
