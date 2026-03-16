{ ... }:
{
    perSystem = { pkgs, config, ... }: {
        devShells.default = pkgs.mkShell {
        inputsFrom = [ config.pre-commit.devShell ];
        packages = with pkgs; [
            nixpkgs-fmt
            nil
            nix-tree
            statix
            deadnix
            sops
            age
            gnupg
        ];
        shellHook = ''
            git config --local core.hooksPath .githooks
            echo "🔧 NixOS flake dev shell ready."
            echo "   nixpkgs-fmt **/*.nix   — format all Nix files"
            echo "   statix check .         — lint"
            echo "   nix flake check        — validate outputs"
            echo "   sops secrets/<file>    — edit encrypted secrets"
        '';
        };
    };
}
