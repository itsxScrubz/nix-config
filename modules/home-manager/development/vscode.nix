{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.vscode or { enable = false; };
    bundleIds = concatMap import (cfg.extensionBundles or []);
    extraIds = cfg.extraExtensions or [];
    allIds = bundleIds ++ extraIds;
    resolveExt = id:
        let parts = splitString "." id;
            pub = elemAt parts 0;
            name = elemAt parts 1;
        in pkgs.vscode-marketplace.${pub}.${name}
            or (builtins.trace "VSCode extension not in marketplace: ${id}" null);
    extensions = filter (x: x != null) (map resolveExt allIds);
in {
    config = mkIf cfg.enable {
        programs.vscode = {
            enable = true;
            package = if pkgs.stdenv.isDarwin
                then (pkgs.emptyDirectory // { pname = "vscode"; version = "latest"; })
                else pkgs.vscode;
            profiles.default = {
                inherit extensions;
                # To manage userSettings declaratively, add a userSettings block here.
            };
        };
    };
}
