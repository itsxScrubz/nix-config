{ hostConfig, ... }:
{
    imports = [ ./_global.nix ];
    networking.hostName = hostConfig.hostName;
    # Automatic garbage collection — weekly, drops generations older than 30 days.
    # Store optimisation still happens inline via `nix.settings.auto-optimise-store` in _global.nix.
    nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
    };
    # ─── mDNS resolution (.local hostnames) ──────────────────────────────────
    # Lets linux hosts resolve other machines on the LAN by hostname (e.g.
    # `mini.local`) without needing router DNS or /etc/hosts. macOS broadcasts
    # mDNS automatically via Bonjour; linux needs avahi-daemon + nss-mdns.
    #
    # Used by the Continue VSCode client profile: `serverHost = "mini.local"`
    # in `modules/home-manager/continue.nix` → apiBase = http://mini.local:11434.
    # mDNS is link-local only — when the laptop is roaming via Tailscale,
    # `mini.local` will NOT resolve. For off-LAN access, use the tailnet FQDN
    # instead (`ai.tail95c8d0.ts.net:11435` for HTTPS). Not wired yet on linux.
    services.avahi = {
        enable = true;
        nssmdns4 = true;              # adds mdns_minimal to /etc/nsswitch.conf
        openFirewall = true;          # allow inbound mDNS queries on 5353/udp
        publish = {
            enable = true;
            addresses = true;         # broadcast this host's own *.local address
            workstation = true;
        };
    };
}
