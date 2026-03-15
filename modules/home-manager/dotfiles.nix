{ lib, userConfig, pkgs, inputs, self, ... }: with lib;
let
    localDir = "${self}/dotfiles";
    githubDir = assert inputs ? dotfiles; inputs.dotfiles;
    dirFor = origin:
        if origin == "github" then githubDir
        else localDir;
    isEnabled = name: (userConfig.${name} or {}).enable or false;
    currentPlatform = if pkgs.stdenv.isDarwin then "darwin" else "linux";
    allEntries = import "${localDir}/entries.nix";
    entries = filter (e:
        isEnabled e.module && elem currentPlatform e.platform
    ) allEntries;
in {
    config = mkIf (entries != []) {
        home.file = mkMerge (map (entry:
        let origin = entry.origin;
        in {
            "${entry.target}".source = "${dirFor origin}/${entry.source}";
        }) entries);
    };
}
