{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "nixd"; }
            { name = "fnm"; }
            { name = "pnpm"; }
        ])
    ];
}
