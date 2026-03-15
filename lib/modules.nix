{ ... }:
{
    mkPlatformModule = targetPlatform: currentPlatform: moduleConfig:
        if targetPlatform == currentPlatform
        then moduleConfig
        else { };
}
