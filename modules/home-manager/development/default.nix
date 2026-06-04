{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "bun"; }
            { name = "nixd"; }
            { name = "fnm"; }
            { name = "python3"; }
            { name = "pipx"; }
            { name = "rustup"; }
        ])
    ];
}
