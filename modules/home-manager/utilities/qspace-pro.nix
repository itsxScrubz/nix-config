{ lib, userConfig, pkgs, self, ... }: with lib;
let
    cfg = userConfig.qspace-pro or { enable = false; };
    qsdataFile = "${self}/dotfiles/qspace-pro/Configuration.qsdata";
in {
    config = mkIf (cfg.enable && pkgs.stdenv.isDarwin) {
        home.file.".config/qspace-pro/Configuration.qsdata".source = qsdataFile;
        home.activation.qspace-pro-import = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            QSDATA="$HOME/.config/qspace-pro/Configuration.qsdata"
            HASH_FILE="$HOME/.config/qspace-pro/.last-imported-hash"
            TARGET_DIR="$HOME/Library/Application Support/com.jinghaoshe.qspace.pro"
            if [ -f "$QSDATA" ]; then
                CURRENT_HASH=$(/usr/bin/shasum -a 256 "$QSDATA" | /usr/bin/cut -d' ' -f1)
                PREVIOUS_HASH=""
                if [ -f "$HASH_FILE" ]; then
                    PREVIOUS_HASH=$(/bin/cat "$HASH_FILE")
                fi
                if [ "$CURRENT_HASH" != "$PREVIOUS_HASH" ]; then
                    /usr/bin/unzip -o "$QSDATA" -d "$TARGET_DIR"
                    echo "$CURRENT_HASH" > "$HASH_FILE"
                fi
            fi
        '';
    };
}
