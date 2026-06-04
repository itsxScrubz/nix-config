[
    # ~ Shell configs.
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/.zshrc";
        target = ".zshrc";
    }
    {
        module = "bash";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/.bashrc";
        target = ".bashrc";
    }
    {
        module = "fish";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/config.fish";
        target = ".config/fish/config.fish";
    }
    # ~ Shared (tied to zsh since it's always enabled).
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" ];
        source = "shell/_shared/ai.sh";
        target = ".config/shell/_shared/ai.sh";
    }
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/_shared/aliases.sh";
        target = ".config/shell/_shared/aliases.sh";
    }
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/_shared/environment.sh";
        target = ".config/shell/_shared/environment.sh";
    }
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/_shared/functions.sh";
        target = ".config/shell/_shared/functions.sh";
    }
    # ~ Nix-specific (only sourced when Nix is installed).
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/_shared/nix.sh";
        target = ".config/shell/_shared/nix.sh";
    }
    # ~ OS-specific.
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" ];
        source = "shell/_shared/os/darwin.sh";
        target = ".config/shell/_shared/os/darwin.sh";
    }
    {
        module = "zsh";
        origin = "local";
        platform = [ "linux" ];
        source = "shell/_shared/os/linux.sh";
        target = ".config/shell/_shared/os/linux.sh";
    }
    # ~ Zsh-specific.
    {
        module = "zsh";
        origin = "local";
        platform = [ "darwin" "linux" ];
        source = "shell/zsh/plugins.zsh";
        target = ".config/shell/zsh/plugins.zsh";
    }
]
