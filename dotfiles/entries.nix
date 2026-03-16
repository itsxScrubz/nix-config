[
    # ~ CLI.
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "zsh/.zshrc";
        target = ".zshrc";
    }
    {
        module = "starship";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "starship/starship.toml";
        target = ".config/starship.toml";
    }
    {
        module = "ghostty";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "ghostty/config";
        target = ".config/ghostty/config";
    }
    # ~ Darwin Specific.
    {
        module = "marta";
        origin = "local";
        platform = [ "darwin" ];
        source = "marta/conf.marco";
        target = "Library/Application Support/org.yanex.marta/conf.marco";
    }
]
