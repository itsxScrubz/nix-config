{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "ghostty"; linuxOnly = true; }
            { name = "starship"; }
        ])
    ];
}
