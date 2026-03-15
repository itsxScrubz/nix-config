{ lib, ... }: with lib;
{
    mkPlatformModule = targetPlatform: currentPlatform: moduleConfig:
        if targetPlatform == currentPlatform
        then moduleConfig
        else { };
    mkHomebrewModules = type: entries: { lib, hostConfig, ... }: with lib; {
        config = mkMerge (map (entry:
            let
                name = if isString entry then entry else entry.name;
                pkg = if isString entry then entry else entry.pkg or entry.name;
                enabled = any (u: u.${name}.enable or false) (attrValues hostConfig.users);
            in mkIf enabled { homebrew.${type} = [ pkg ]; }
        ) entries);
    };
    mkSimpleHomeModules = modules: { lib, userConfig, pkgs, ... }: with lib; {
        config = mkMerge (map (mod:
            let
                name = mod.name;
                pkg = mod.pkg or name;
                linuxOnly = mod.linuxOnly or false;
                cfg = userConfig.${name} or { enable = false; };
                platformCheck = if linuxOnly then pkgs.stdenv.isLinux else true;
            in mkIf (cfg.enable && platformCheck) {
                home.packages = [ pkgs.${pkg} ];
            }
        ) modules);
    };
    mkSimpleSystemModules = modules: { lib, hostConfig, pkgs, ... }: with lib; {
        config = mkMerge (map (mod:
            let
                name = mod.name;
                pkg = mod.pkg or name;
                enabled = any (u: u.${name}.enable or false) (attrValues hostConfig.users);
            in mkIf enabled {
                environment.systemPackages = [ pkgs.${pkg} ];
            }
        ) modules);
    };
}
