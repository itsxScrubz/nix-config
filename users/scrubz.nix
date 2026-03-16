{
    bundles = [
        # ./pkgBundles/developer.nix
        # ./pkgBundles/creative.nix
        # ./pkgBundles/gaming.nix
    ];
    git.userName = "itsxScrubz";
    git.userEmail = "49043506+itsxScrubz@users.noreply.github.com";
    # ~ Browsers.
    google-chrome.enable = false;
    vivaldi.enable = true;
    # ~ Fonts.
    firacode-nerd-font.enable = true;
    # ~ CLI.
    claude-code.enable = true;
    direnv.enable = true;
    ghostty.enable = true;
    git.enable = true;
    starship.enable = true;
    mas.enable = true;
    zoxide.enable = true;
    zsh.enable = true;
    # ~ Communication.
    discord.enable = true;
    # ~ Development.
    nixd.enable = true;
    vscode.enable = true;
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
    masApps = {
        Xcode = 497799835;
        LINE = 539883307;
    };
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
        { path = "/Applications/Discord.app/"; }
        { path = "/Applications/Visual Studio Code.app/"; }
        { path = "/Applications/Xcode.app/"; }
        { path = "/Applications/Ghostty.app/"; }
        { path = "/Applications/LINE.app/"; }
    ];
}
