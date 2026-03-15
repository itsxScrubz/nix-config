{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleSystemModules [
            { name = "zoxide"; }
        ])
    ];
}
