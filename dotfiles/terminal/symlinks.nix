[
    {
        module = "starship";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "terminal/starship.toml";
        target = ".config/starship.toml";
    }
    {
        module = "ghostty";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "terminal/ghostty.config";
        target = ".config/ghostty/config";
    }
]
