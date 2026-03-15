{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "discord"; linuxOnly = true; }
        ])
    ];
}
