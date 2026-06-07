{ myLib, ... }: {
    imports = [
        (myLib.mkHomebrewModules "brews" [
            "caddy"
            # ollama moved off the homebrew *formula*: homebrew-core's ollama
            # 0.30.x build only compiles the go binary + MLX imagegen runner and
            # never builds the llama.cpp `llama-server` runner, so every GGUF
            # model fails with "llama-server binary not found". The official cask
            # (below) ships prebuilt runners. See hosts/mini/ollama.nix.
        ])
        (myLib.mkHomebrewModules "casks" [
            "claude-code"
            "ollama-app"
            "tailscale-app"
        ])
    ];
}
