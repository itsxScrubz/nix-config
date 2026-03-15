{ pkgs }:

pkgs.writeShellApplication {
    name = "newModule";
    text =
''
usage() {
    cat <<USAGE
Usage: newModule <type> <category> <name>

Type flags:
    -s,  --system       System module (with environment.systemPackages)
    -sn, --system-np    System module without a package (empty config block)
    -bc, --brew-cask     Homebrew cask module
    -bf, --brew-formula  Homebrew formula module
    -h,  --home         Home-manager module (with home.packages)

Examples:
    newModule -s cli zsh
    newModule -sn utilities discord-udev
    newModule -bc browsers vivaldi
    newModule -bf cli coreutils
    newModule -h browsers firefox
USAGE
    exit 1
}

[ "$#" -lt 3 ] && usage

cd "$HOME/Projects/nix-config" || exit 1

TYPE="$1"
CATEGORY="$2"
NAME="$3"

case "$TYPE" in
    -s  | --system)    DIR="modules/system/$CATEGORY"      ;;
    -sn | --system-np) DIR="modules/system/$CATEGORY"      ;;
    -bc | --brew-cask)    DIR="modules/homebrew/$CATEGORY"     ;;
    -bf | --brew-formula) DIR="modules/homebrew/$CATEGORY"     ;;
    -h  | --home)      DIR="modules/home-manager/$CATEGORY" ;;
    *)                 echo "Unknown type: $TYPE" >&2; usage ;;
esac

FILE="$DIR/$NAME.nix"

if [ -f "$FILE" ]; then
    echo "File already exists: $FILE" >&2
    exit 1
fi

mkdir -p "$DIR"

case "$TYPE" in
    -s | --system) cat > "$FILE" <<NIX
{ lib, hostConfig, pkgs, ... }: with lib;
let
    cfg = { enable = any (u: u.$NAME.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        environment.systemPackages = with pkgs; [ $NAME ];
    };
}
NIX
;;
    -sn | --system-np) cat > "$FILE" <<NIX
{ lib, hostConfig, pkgs, ... }: with lib;
let
    cfg = { enable = any (u: u.$NAME.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        # Add your configuration here
    };
}
NIX
;;
    -bc | --brew-cask) cat > "$FILE" <<NIX
{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.$NAME.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.casks = [ "$NAME" ];
    };
}
NIX
;;
    -bf | --brew-formula) cat > "$FILE" <<NIX
{ lib, hostConfig, ... }: with lib;
let
    cfg = { enable = any (u: u.$NAME.enable or false) (attrValues hostConfig.users); };
in {
    config = mkIf cfg.enable {
        homebrew.brews = [ "$NAME" ];
    };
}
NIX
;;
    -h | --home) cat > "$FILE" <<NIX
{ lib, userConfig, pkgs, ... }: with lib;
let
    cfg = userConfig.$NAME or { enable = false; };
in {
    config = mkIf cfg.enable {
        home.packages = with pkgs; [ $NAME ];
    };
}
NIX
;;
esac

echo "Created $FILE"
'';
}
