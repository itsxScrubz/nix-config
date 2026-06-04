{ lib, userConfig, config, ... }: with lib;
let
    cfg = userConfig.ssh or { enable = false; };
    servers = cfg.servers or {};
in {
    config = mkIf cfg.enable {
        # ~ Declare sops secrets for each server's SSH private key.
        sops.secrets = mapAttrs' (name: _:
            nameValuePair "ssh/${name}_private_key" { mode = "0600"; }
        ) servers;
        # ~ Wire SSH host entries for each server (new settings API).
        programs.ssh = {
            enable = true;
            settings = mapAttrs (name: serverCfg:
                {
                    HostName = serverCfg.host or "";
                    User = serverCfg.user or "scrubz";
                    IdentityFile = config.sops.secrets."ssh/${name}_private_key".path;
                } // (serverCfg.extraOptions or {})
            ) servers;
        };
    };
}
