{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "nil"; }
        ])
    ];
}
