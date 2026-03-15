{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.duti.enable or false) (attrValues hostConfig.users); };
    bundleId = "com.microsoft.VSCode";
    extensions = [
        # Web
        # "html" "htm" # html/htm are protected at the OS level -_-
        "css" "js" "jsx" "ts" "tsx" "vue" "svelte"
        # Languages.
        "py" "rb" "go" "rs" "java" "kt" "swift" "c" "cpp" "h" "cs" "lua" "zig"
        # Scripting.
        "sh" "bash" "zsh" "fish"
        # Nix.
        "nix"
        # Config files.
        "dockerfile" "tf" "hcl" "lock" "gitignore" "editorconfig" "prettierrc" "eslintrc"
        # Data.
        "sql" "graphql" "prisma" "proto" "rst" "tex"
        # Misc.
        "md" "txt" "json" "yaml" "yml" "toml" "xml" "csv" "ini" "cfg" "conf" "env" "log"
    ];
    dutiCmds = concatStringsSep "\n" (map (ext:
        "duti -s ${bundleId} .${ext} all"
    ) extensions);
    enabledUsers = filterAttrs (_: u: u.duti.enable or false) hostConfig.users;
    mkUserDutiScript = name: _: ''
        echo "Setting duti file associations for ${name}..." >&2
        sudo -u ${name} sh -c '
            PATH="/opt/homebrew/bin:$PATH"
            ${dutiCmds}
        '
    '';
in {
    config = mkIf cfg.enable {
        homebrew.brews = [ "duti" ];
        system.activationScripts.postActivation.text = ''
            if [ -x /opt/homebrew/bin/duti ]; then
                ${concatStringsSep "\n" (mapAttrsToList mkUserDutiScript enabledUsers)}
            fi
        '';
    };
}
