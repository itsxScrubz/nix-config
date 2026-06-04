{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "steam"; linuxOnly = true; }
        ])
    ];
}
