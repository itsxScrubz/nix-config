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
        # ~ Wire SSH match blocks for each server.
        programs.ssh = {
            enable = true;
            matchBlocks = mapAttrs (name: serverCfg: {
                hostname = serverCfg.host or "";
                user = serverCfg.user or "scrubz";
                identityFile = config.sops.secrets."ssh/${name}_private_key".path;
            } // optionalAttrs (serverCfg ? extraOptions) {
                extraOptions = serverCfg.extraOptions;
            }) servers;
        };
    };
}
