{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "casks" [
            "alt-tab"
            "dockdoor"
            "hiddenbar"
            "qspace-pro"
            "swift-shift"
            { name = "_1password"; pkg = "1password"; }
        ])
    ];
}
