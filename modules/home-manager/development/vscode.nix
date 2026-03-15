{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.vscode or { enable = false; extraExtensions = []; };
    extensionPackages =
        map
        (id:
            let parts = splitString "." id;
                pub = elemAt parts 0;
                name = elemAt parts 1;
            in pkgs.vscode-marketplace.${pub}.${name}
            or (builtins.trace "VSCode extension not in marketplace: ${id}" null))
        (cfg.extraExtensions or []);
    validExtensions = filter (x: x != null) extensionPackages;
in {
    config = mkIf cfg.enable {
        programs.vscode = {
            enable = true;
            package = if pkgs.stdenv.isDarwin then (pkgs.emptyDirectory // { pname = "vscode"; version = "latest"; }) else pkgs.vscode;
            profiles.default = {
                extensions = with pkgs.vscode-marketplace; validExtensions ++ [
                    aaron-bond.better-comments
                    adpyke.codesnap
                    albert.tabout
                    anthropic.claude-code
                    arrterian.nix-env-selector
                    arturodent.comment-blocks
                    atommaterial.a-file-icon-vscode
                    bbenoist.qml
                    bierner.jsdoc-markdown-highlighting
                    biomejs.biome
                    bmalehorn.vscode-fish
                    bradlc.vscode-tailwindcss
                    cardinal90.multi-cursor-case-preserve
                    crystal-spider.jsdoc-generator
                    diemasmichiels.emulate
                    docker.docker
                    eamodio.gitlens
                    ecmel.vscode-html-css
                    editorconfig.editorconfig
                    esbenp.prettier-vscode
                    foxundermoon.shell-format
                    george3447.docker-run
                    github.remotehub
                    github.vscode-github-actions
                    jnoortheen.nix-ide
                    johnpapa.vscode-peacock
                    kamikillerto.vscode-colorize
                    ms-vscode.makefile-tools
                    mongodb.mongodb-vscode
                    mrmlnc.vscode-scss
                    ms-azuretools.vscode-containers
                    ms-vscode-remote.remote-containers
                    ms-vscode-remote.remote-ssh
                    ms-vscode-remote.remote-ssh-edit
                    ms-vscode.azure-repos
                    ms-vscode.extension-test-runner
                    ms-vscode.powershell
                    ms-vscode.remote-explorer
                    ms-vscode.remote-repositories
                    oderwat.indent-rainbow
                    prisma.prisma
                    quicktype.quicktype
                    redhat.vscode-xml
                    redhat.vscode-yaml
                    ritwickdey.liveserver
                    seyyedkhandon.firacode
                    sumneko.lua
                    svelte.svelte-vscode
                    syler.sass-indented
                    tonybaloney.vscode-pets
                    yzhang.markdown-all-in-one
                    zhuangtongfa.material-theme
                ];
                # You can uncomment this to manage vscode user settings directly
                # with the nix flake.
                /*
                userSettings = {
                    "editor.fontSize" = 14;
                    "editor.fontFamily" = "'Fira Code', monospace";
                    "editor.formatOnSave" = true;
                    "editor.tabSize" = 2;
                    "workbench.colorTheme" = "One Dark Pro Darker";
                    "terminal.integrated.defaultProfile.linux" = "zsh";
                    "terminal.integrated.defaultProfile.osx" = "zsh";
                    "workbench.startupEditor" = "none";
                    "workbench.iconTheme" = "a-file-icon-vscode";
                    "workbench.productIconTheme" = "a-file-icon-vscode-product-icon-theme";
                };
                */
            };
        };
    };
}
