{ hostConfig, ... }:
{
    imports = [ ./_global.nix ];
    networking.hostName = hostConfig.hostName;
}
