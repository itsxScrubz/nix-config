{ ... }:
{
    imports = [ ../_shared/linux.nix ];
    # ~ sops-nix system-level config.
    sops.defaultSopsFile = ../../secrets/laptop.yaml;
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.secrets."wifi/home_psk" = {};
    # ~ Wi-Fi via sops secret.
    # environmentFile needs KEY=VALUE format; pskFile takes raw PSK.
    # networking.wireless.environmentFile = config.sops.secrets."wifi/home_psk".path;
    # networking.wireless.networks."MyNetwork".pskRaw = "ext:home_psk";
}
