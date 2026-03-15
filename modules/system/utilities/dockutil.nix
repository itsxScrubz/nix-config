{ lib, hostConfig, pkgs, myLib, platform, ... }: with lib;
let
    cfg = { enable = any (u: u.dockutil.enable or false) (attrValues hostConfig.users); };
    mkUserDockScript = name: userConfig:
        let
            entries = userConfig.dockutil.entries or [];
            plist = "/Users/${name}/Library/Preferences/com.apple.dock.plist";
            addEntries = concatMapStrings (e:
                let
                    section = optionalString (e.section or "apps" != "apps") " --section ${e.section}";
                    extraOpts = optionalString (e.options or "" != "") " ${e.options}";
                in ''
                    ${pkgs.dockutil}/bin/dockutil --no-restart --add ${escapeShellArg e.path}${section}${extraOpts} \
                        ${plist}
                ''
            ) entries;
        in
        optionalString (entries != []) ''
            echo "Setting up Dock for ${name}..." >&2
            ${pkgs.dockutil}/bin/dockutil --no-restart --remove all ${plist}
            ${addEntries}
        '';
    allDockScripts = concatStringsSep "\n"
        (mapAttrsToList mkUserDockScript hostConfig.users);
    anyEntriesConfigured = builtins.any
        (u: (u.dockutil.entries or []) != [])
        (builtins.attrValues hostConfig.users);
in
myLib.mkPlatformModule "darwin" platform {
    config = mkIf cfg.enable {
        system.activationScripts.extraActivation.text =
            optionalString anyEntriesConfigured ''
                ${allDockScripts}
                /usr/bin/killall Dock || true
            '';
    };
}
