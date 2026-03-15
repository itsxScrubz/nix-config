{
    bundles = [
        ./pkgBundles/developer.nix
        ./pkgBundles/creative.nix
        ./pkgBundles/gaming.nix
    ];
    git.userName = "itsxScrubz";
    git.userEmail = "49043506+itsxScrubz@users.noreply.github.com";
    # ~ Browsers.
    vivaldi.enable = true;
    # ~ CLI.
    claude-code.enable = true;
    ghostty.enable = true;
    git.enable = true;
    mas.enable = true;
    zsh.enable = true;
    # ~ Communication.
    discord.enable = true;
    # ~ Development.
    nixLang.enable = true;
    vscode.enable = true;
    # ~ Hardware.
    logitech-g-hub.enable = true;
    # ~ Utilities.
    expressvpn.enable = false;
    flameshot.enable = true;
    # ~ MacOS Specific.
    alt-tab.enable = true;
    android-studio.enable = false;
    coreutils.enable = true;
    dockutil.enable = true;
    macAppUtil.enable = true;
    qspace-pro.enable = true;
    swift-shift.enable = true;
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
        { path = "/Users/scrubz/Applications/Home Manager Apps/Discord.app/"; }
        { path = "/Applications/Visual Studio Code.app/"; }
        { path = "/Applications/Xcode.app/"; }
        { path = "/Applications/Ghostty.app/"; }
        { path = "/Applications/LINE.app/"; }
    ];
}
