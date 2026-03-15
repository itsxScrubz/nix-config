{ lib, userConfig, config, ... }: with lib;
let
    cfg = userConfig.git or { enable = false; };
in {
    config = mkIf cfg.enable {
        # ~ Declare sops secrets (defaultSopsFile is inherited from home.nix).
        sops.secrets."git/ssh_private_key" = {
            mode = "0600";
        };
        sops.secrets."git/ssh_signing_key" = {
            mode = "0600";
        };
        # ~ Generate an allowed signers file from the signing key for verification.
        home.file.".config/git/allowed_signers".text =
            "${cfg.userEmail} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICND0bjyXoz7cWzzI9EfUiMCZtb3ZfFyyyASkMFS4b/e";
        programs.git = {
            enable = true;
            settings.user.name = cfg.userName;
            settings.user.email = cfg.userEmail;
            settings.gpg.ssh.allowedSignersFile = "~/.config/git/allowed_signers";
            signing = {
                key = config.sops.secrets."git/ssh_signing_key".path;
                format = "ssh";
                signByDefault = true;
            };
        };
        # ~ Wire SSH private key for git authentication.
        programs.ssh = {
            enable = true;
            enableDefaultConfig = false;
            matchBlocks."github.com" = {
                identityFile = config.sops.secrets."git/ssh_private_key".path;
            };
        };
    };
}
