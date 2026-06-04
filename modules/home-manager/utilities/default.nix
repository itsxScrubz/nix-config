{ myLib, ... }: {
    imports = [
        (myLib.mkSimpleHomeModules [
            { name = "expressvpn"; linuxOnly = true; }
            { name = "flameshot"; linuxOnly = true; }
        ])
    ];
}
