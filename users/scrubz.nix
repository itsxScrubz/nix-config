{
    bundles = [
        # ./pkgBundles/developer.nix
        # ./pkgBundles/creative.nix
        # ./pkgBundles/gaming.nix
    ];
    git.userName = "itsxScrubz";
    git.userEmail = "49043506+itsxScrubz@users.noreply.github.com";
    ssh.servers."scrubz.dev" = {
        host = "ssh.scrubz.dev";
        user = "scrubz";
        extraOptions = {
            SetEnv.TERM = "xterm";
        };
    };
    # ~ AI.
    caddy.enable = true;
    claude-code.enable = true;
    ollama.enable = true;
    tailscale-app.enable = true;
    # ~ Browsers.
    google-chrome.enable = false;
    vivaldi.enable = true;
    # ~ Fonts.
    firacode-nerd-font.enable = true;
    # ~ CLI.
    direnv.enable = true;
    ghostty.enable = true;
    git.enable = true;
    starship.enable = true;
    mas.enable = true;
    zoxide.enable = true;
    ssh.enable = true;
    zsh.enable = true;
    # ~ Communication.
    discord.enable = true;
    # ~ Development.
    adobe-creative-cloud.enable = true;
    bun.enable = true;
    docker-desktop.enable = true;
    fnm.enable = true;
    nixd.enable = true;
    pipx.enable = true;
    postgresql.enable = true;
    python3.enable = true;
    rustup.enable = true;
    vscode.enable = true;
    # ~ Gaming.
    steam.enable = true;
    # ~ Hardware.
    logitech-g-hub.enable = true;
    # ~ Utilities.
    _1password.enable = true;
    age.enable = true;
    expressvpn.enable = false;
    flameshot.enable = true;
    # ~ MacOS Specific.
    alt-tab.enable = true;
    android-studio.enable = true;
    coreutils.enable = true;
    dockdoor.enable = true;
    duti.enable = true;
    dockutil.enable = true;
    hiddenbar.enable = true;
    macAppUtil.enable = true;
    qspace-pro.enable = true;
    swift-shift.enable = true;
    # ~ Settings.
    vscode.extensionBundles = [
        ./pkgBundles/vscode/core.nix
        ./pkgBundles/vscode/web.nix
        ./pkgBundles/vscode/devops.nix
        ./pkgBundles/vscode/languages.nix
        ./pkgBundles/vscode/data.nix
        ./pkgBundles/vscode/git.nix
    ];
    # vscode.extraExtensions = [ "publisher.one-off-extension" ];
    # ~ masApps disabled wholesale: nix-homebrew's brew shim filters PATH before invoking
    # ~ `brew bundle install`, so `package_manager_installed?` (which looks for `mas` on
    # ~ ORIGINAL_PATHS) fails even though mas is installed at /opt/homebrew/bin/mas. Every
    # ~ App Store entry then errors as "Unable to install <name> app. mas installation
    # ~ failed.", blocking activation. Apps remain installed and update via the App Store
    # ~ GUI. Re-enable once nix-homebrew (or upstream brew) lets the PATH through.
    # masApps = {
    #     Xcode = 497799835;
    #     LINE = 539883307;
    #     TheUnarchiver = 425424353;
    # };
    desktop = {
        titleBarDoubleClick = "Fill";
    };
    finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        NewWindowTarget = "Home";
        FXPreferredViewStyle = "icnv";
        FXDefaultSearchScope = "SCcf";
        ShowPathbar = true;
        ShowStatusBar = true;
        _FXShowPosixPathInTitle = true;
        _FXSortFoldersFirst = true;
        FXEnableExtensionChangeWarning = false;
        QuitMenuItem = true;
    };
    dockutil.entries = [
        { path = "/Applications/QSpace Pro.app/"; }
        { path = "/Applications/Vivaldi.app/"; }
        { path = "/Applications/Visual Studio Code.app/"; }
        { path = "/Applications/Xcode.app/"; }
        { path = "/Applications/Ghostty.app/"; }
        { path = "/Applications/Discord.app/"; }
        { path = "/Applications/LINE.app/"; }
        { path = "/Applications/Mail.app/"; }
    ];
}
