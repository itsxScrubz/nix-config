{ inputs, ... }:
{
    imports = [ inputs.git-hooks.flakeModule ];
    perSystem = { pkgs, ... }: {
        pre-commit.settings.hooks = {
            commitlint = {
                enable = true;
                stages = [ "commit-msg" ];
                entry = "${pkgs.commitlint}/bin/commitlint --edit";
            };
        };
    };
}
