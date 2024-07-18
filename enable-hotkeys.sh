#!/bin/bash

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")"
#add the keybindings
#reset zoom 100%
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-zoom/binding "'KP_Divide'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-zoom/command "'$SCRIPT_DIR/cam-control.sh \'Zoom, Absolute\' 100'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-zoom/name "'Zoom Table 100%'"
#reset zoom 400%
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-400/binding "'KP_Multiply'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-400/command "'$SCRIPT_DIR/cam-control.sh \'Zoom, Absolute\' 400'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-400/name "'Zoom Table 400%'"
#zoom in
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-in/binding "'KP_Add'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-in/command "'$SCRIPT_DIR/cam-control.sh \'Zoom, Absolute\' +10'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-in/name "'Zoom Table In'"
#zoom out
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-out/binding "'KP_Subtract'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-out/command "'$SCRIPT_DIR/cam-control.sh \'Zoom, Absolute\' -10'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-out/name "'Zoom Table Out'"
#reset pan/tilt
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-pantilt/binding "'KP_5'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-pantilt/command "'$SCRIPT_DIR/cam-control.sh \'Pan, Absolute\' 18000 \'Tilt, Absolute\' 0'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-pantilt/name "'Reset Pan/Tilt'"
#pan up
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-up/binding "'KP_8'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-up/command "'$SCRIPT_DIR/cam-control.sh \'Pan, Absolute\' +2000'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-up/name "'Pan Up'"
#pan down
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-down/binding "'KP_2'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-down/command "'$SCRIPT_DIR/cam-control.sh \'Pan, Absolute\' -2000'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-down/name "'Pan Down'"
#pan left
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-left/binding "'KP_4'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-left/command "'$SCRIPT_DIR/cam-control.sh \'Tilt, Absolute\' -2000'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-left/name "'Pan Left'"
#pan right
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-right/binding "'KP_6'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-right/command "'$SCRIPT_DIR/cam-control.sh \'Tilt, Absolute\' +2000'"
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-right/name "'Pan Right'"
#pan right
# dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-1/binding "'Calculator'"
# dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-1/command "'$SCRIPT_DIR/cam-control.sh first'"
# dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-1/name "'Camera 1'"
#update keybinding keys
CURRENT_KEYBINDINGS=($(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings | tr -d '[]' | tr , "\n" | head -c-1))
NEW_KEYBINDINGS=
# echo "CURRENT_KEYBINDINGS=${CURRENT_KEYBINDINGS[*]}"
for i in "${CURRENT_KEYBINDINGS[@]}"; do
    EXISTING_KEY="$(echo "$i" | tr -d "'")"
    if [[ "$EXISTING_KEY" =~ .+custom-cam-.+/$ ]]; then
        #skip over old entries
        echo "Skipping: '$EXISTING_KEY'"
    else
        #keep non-cam keybinding keys
        NEW_KEYBINDINGS+=( "$EXISTING_KEY" )
        echo "Adding: '$EXISTING_KEY'"
    fi
done
#add new keybinding keys
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-zoom/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-400/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-in/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-zoom-out/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-reset-pantilt/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-up/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-down/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-left/' )
NEW_KEYBINDINGS+=( '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-cam-pan-right/' )
DCONF_VALUE=$(printf ",'%s'" "${NEW_KEYBINDINGS[@]}")
DCONF_VALUE="[${DCONF_VALUE:1}]"
# echo $DCONF_VALUE
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$DCONF_VALUE"
echo "Hotkeys Enabled"
