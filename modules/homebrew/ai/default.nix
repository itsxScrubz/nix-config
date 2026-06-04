{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "brews" [
            "caddy"
            "ollama"
        ])
        (myLib.mkHomebrewModules "casks" [
            "claude-code"
            "tailscale-app"
        ])
    ];
}
