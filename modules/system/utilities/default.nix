{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleSystemModules [
            { name = "age"; }
        ])
    ];
}
