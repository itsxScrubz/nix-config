{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "nixd"; }
        ])
    ];
}
