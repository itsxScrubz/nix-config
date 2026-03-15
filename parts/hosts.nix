{ inputs, lib, self, ... }: with lib;
let
    # ~ Host configs.
    # ! You MUST use the hostConfigs.myMachineName naming structure
    # ! in order for the flake to automatically pick up the right
    # ! machine to rebuild for.
    hostConfigs = {
        mini = { platform = "darwin"; system = "aarch64-darwin"; };
        laptop = { platform = "linux";  system = "x86_64-linux";   };
    };
    darwinSystem = inputs.nix-darwin.lib.darwinSystem;
    linuxSystem = inputs.nixpkgs.lib.nixosSystem;
    # ~ Lib helpers.
    myLib = import ../lib/modules.nix { inherit lib; };
    # ~ Load host config and modules.
    loadHostConfig = hostName:
    let
        baseConfig = import ../hosts/${hostName}/config.nix;
    in baseConfig // {
        users = builtins.mapAttrs (_: userConfig:
            let
                bundles = userConfig.bundles or [];
                merged = foldl' recursiveUpdate {} (map import bundles);
                config = removeAttrs userConfig [ "bundles" ];
            in recursiveUpdate merged config
        ) baseConfig.users;
    };
    systemModules = [ (inputs.import-tree [ ../modules/system ]) ];
    homebrewModules = [ (inputs.import-tree [ ../modules/homebrew ]) ];
    # ~ HM modules (auto-discovered, applied per-user).
    hmModules = inputs.import-tree [ ../modules/home-manager ];
    # ~ Standalone home-manager config for a single user on a given host.
    mkHomeConfig = hostName: userName: userConfig: { system, platform, ... }:
    let
        hostConfig = loadHostConfig hostName;
        pkgs = import inputs.nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ inputs.nix-vscode-extensions.overlays.default ];
        };
        platformModules = optionals (platform == "darwin") [
            inputs.mac-app-util.homeManagerModules.default
        ];
    in
    inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
            ../hosts/_shared/home.nix
            inputs.sops-nix.homeManagerModules.sops
            hmModules
        ] ++ platformModules ++ [
            { _module.args.userConfig = userConfig; }
            { _module.args.userName = userName;   }
        ];
        extraSpecialArgs = { inherit inputs hostConfig self myLib; };
    };
    # ~ Darwin host setup (system-level only; home-manager is standalone).
    mkDarwinHost = hostName: { system, ... }:
    let
        hostConfig = loadHostConfig hostName;
        primaryUser = hostConfig.primaryUser;
    in
    darwinSystem {
        inherit system;
        specialArgs = { inherit inputs hostConfig myLib; platform = "darwin"; };
        modules = systemModules ++ homebrewModules ++ [
            (import ../hosts/${hostName})
            inputs.nix-homebrew.darwinModules.nix-homebrew
            inputs.mac-app-util.darwinModules.default
            {
                nix-homebrew = {
                    enable = true;
                    enableRosetta = true;
                    user = primaryUser;
                    taps = {
                        "homebrew/homebrew-core" = inputs.homebrew-core;
                        "homebrew/homebrew-cask" = inputs.homebrew-cask;
                        "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
                    };
                    mutableTaps = false;
                };
            }
            {
                users.users = mapAttrs (name: _: {
                    name = name;
                    home = "/Users/${name}";
                }) hostConfig.users;
            }
        ];
    };
    # ~ Linux host setup (system-level only; home-manager is standalone).
    mkNixosHost = hostName: { system, ... }:
    let
        hostConfig = loadHostConfig hostName;
    in
    linuxSystem {
        inherit system;
        specialArgs = { inherit inputs hostConfig myLib; platform = "linux"; };
        modules = systemModules ++ [
            inputs.sops-nix.nixosModules.sops
            (import ../hosts/${hostName})
            {
                users.users = mapAttrs (name: _: {
                    name = name;
                    home = "/home/${name}";
                    isNormalUser = true;
                    extraGroups = [ "wheel" "sudo" ];
                }) hostConfig.users;
            }
        ];
    };
    # ~ Generate homeConfigurations for every user on every host.
    mkHomeConfigs = hostName: meta:
    let
        hostConfig = loadHostConfig hostName;
    in
    mapAttrs' (userName: userConfig:
        nameValuePair "${userName}@${hostName}"
            (mkHomeConfig hostName userName userConfig meta)
    ) hostConfig.users;
    homeConfigs = foldl' mergeAttrs {} (mapAttrsToList (_: v: v) (mapAttrs mkHomeConfigs hostConfigs));
    # ~ Setup hosts.
    mkHost = hostName: meta:
        if meta.platform == "linux"
        then { nixos = mkNixosHost hostName meta; }
        else { darwin = mkDarwinHost hostName meta; };
    builtHosts = mapAttrs mkHost hostConfigs;
    nixosHosts = filterAttrs (_: v: v ? nixos)  builtHosts;
    darwinHosts = filterAttrs (_: v: v ? darwin) builtHosts;
in {
    flake.nixosConfigurations = mapAttrs (_: v: v.nixos)  nixosHosts;
    flake.darwinConfigurations = mapAttrs (_: v: v.darwin) darwinHosts;
    flake.homeConfigurations = homeConfigs;
}
