{ lib, ... }: with lib;
{
    perSystem = { pkgs, ... }:
    let
        appFiles = builtins.readDir ../apps;
        apps = builtins.listToAttrs (map (name:
            let
                baseName = removeSuffix ".nix" name;
                drv = import ../apps/${name} { inherit pkgs; };
            in {
                name = baseName;
                value = { type = "app"; program = "${drv}/bin/${baseName}"; };
            }
        ) (builtins.attrNames (filterAttrs (n: v: v == "regular" && hasSuffix ".nix" n) appFiles)));
    in {
        inherit apps;
    };
}
