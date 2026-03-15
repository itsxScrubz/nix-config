{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            { name = "vscode"; pkg = "visual-studio-code"; }
            "android-studio"
        ])
    ];
}
