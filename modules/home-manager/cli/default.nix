{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "claude-code"; }
            { name = "ghostty"; linuxOnly = true; }
            { name = "starship"; }
        ])
    ];
}
