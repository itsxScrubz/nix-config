{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "vivaldi"; linuxOnly = true; }
            { name = "google-chrome"; linuxOnly = true; }
        ])
    ];
}
