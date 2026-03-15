{ lib }: with lib;
{
    mkUserConfig = userConfig:
        let
            bundles = userConfig.bundles or [];
            merged = foldl' recursiveUpdate {} (map import bundles);
            config = removeAttrs userConfig [ "bundles" ];
        in recursiveUpdate merged config;
}
