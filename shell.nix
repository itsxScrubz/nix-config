{ pkgs ? import <nixpkgs> { }, ... }: {
    default = pkgs.mkShell {
        NIX_CONFIG = "extra-experimental-features = nix-command flakes ca-derivations";
        nativeBuildInputs = with pkgs; [
            bashInteractive
            nix
            git
            home-manager
            nixos-rebuild
            nixpkgs-fmt
            statix
            deadnix
            nil
            nix-tree
            nix-diff
        ];
        shellHook = ''
            echo ""
            echo "  🔧 NixOS/nix-darwin flake dev shell"
            echo ""
            echo "  Rebuild commands:"
            echo "    nixos-rebuild switch --flake .#<host>    (Linux)"
            echo "    darwin-rebuild switch --flake .#<host>   (macOS)"
            echo ""
            echo "  Flake maintenance:"
            echo "    nix flake update              update all inputs"
            echo "    nix flake update nixpkgs      update one input"
            echo "    nix flake check               validate all outputs"
            echo ""
            echo "  Code quality:"
            echo "    nixpkgs-fmt **/*.nix          format"
            echo "    statix check .                lint"
            echo "    deadnix .                     find dead code"
            echo ""
        '';
    };
}
