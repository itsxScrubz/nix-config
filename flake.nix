{
    description = "ScrubzOS";
    # ~ Caching for faster rebuilds.
    nixConfig = {
        # TODO: Add private caching server.
        extra-substituters = [
            "https://nix-community.cachix.org"
        ];
        extra-trusted-public-keys = [
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
    };
    inputs = {
        # ~ Nix ecosystem.
        nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
        home-manager.url = "github:nix-community/home-manager";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";
        systems.url = "github:nix-systems/default";
        disko.url = "github:nix-community/disko";
        disko.inputs.nixpkgs.follows = "nixpkgs";
        sops-nix.url = "github:Mic92/sops-nix";
        sops-nix.inputs.nixpkgs.follows = "nixpkgs";
        # ~ Darwin ecosystem.
        nix-darwin.url = "github:LnL7/nix-darwin/master";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
        nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
        homebrew-core.url = "github:homebrew/homebrew-core";
        homebrew-core.flake = false;
        homebrew-cask.url = "github:homebrew/homebrew-cask";
        homebrew-cask.flake = false;
        homebrew-bundle.url = "github:homebrew/homebrew-bundle";
        homebrew-bundle.flake = false;
        mac-app-util.url = "github:hraban/mac-app-util";
        # ~ Flake specific.
        flake-parts.url = "github:hercules-ci/flake-parts";
        import-tree.url = "github:vic/import-tree";
        git-hooks.url = "github:cachix/git-hooks.nix";
        git-hooks.inputs.nixpkgs.follows = "nixpkgs";
        # ~ Dotfiles (uncomment once repo exists).
        # dotfiles.url = "github:scrubz/dotfiles";
        # dotfiles.flake = false;
        # ~ Misc.
        nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
        nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
    };
    outputs = inputs @ { flake-parts, import-tree, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
        imports = [ (import-tree [ ./parts ]) ];
        systems = import inputs.systems;
    };
}
