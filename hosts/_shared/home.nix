{ hostConfig, pkgs, userName, self, config, ... }:
{
    home.username = userName;
    home.stateVersion = hostConfig.stateVersion.home-manager;
    home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin
        then "/Users/${userName}"
        else "/home/${userName}";
    programs.home-manager.enable = true;
    # ! Disabling until they fix this issue upstream.
    # warning: Using 'builtins.derivation' to create a derivation named 'options.json'
    # that references the store path '/nix/store/w2jcgb8c6yph72nsksa6zmc8qdna8ys4-source'
    # without a proper context. The resulting derivation will not have a correct store
    # reference, so this is unreliable and may stop working in the future.
    manual.manpages.enable = false;
    manual.html.enable = false;
    # ~ sops-nix base config.
    sops.defaultSopsFile = "${self}/secrets/${userName}.yaml";
    sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
}
