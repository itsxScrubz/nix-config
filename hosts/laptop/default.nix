{ ... }:
{
    imports = [ ../_shared/linux.nix ];
    # ~ sops-nix system-level config.
    sops.defaultSopsFile = ../../secrets/laptop.yaml;
    sops.age.keyFile = "/var/lib/sops-nix/key.txt";
    sops.secrets."wifi/home_psk" = {};
    # ~ Wi-Fi (uses sops secret via environmentFile).
    # TODO: Verify networking.wireless.environmentFile option exists in pinned nixpkgs.
    # The environmentFile expects KEY=VALUE format, so the sops secret must be structured
    # as "home_psk=<actual-psk-value>" rather than just the raw PSK value.
    # Alternatively, consider using networking.wireless.networks."<name>".pskFile if
    # the option accepts a file path containing just the PSK.
    # networking.wireless.environmentFile = config.sops.secrets."wifi/home_psk".path;
    # networking.wireless.networks."MyNetwork".pskRaw = "ext:home_psk";
}
