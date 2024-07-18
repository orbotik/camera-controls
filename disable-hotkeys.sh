#!/bin/bash

#grab existing keybindings
CURRENT_KEYBINDINGS=($(dconf read /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings | tr -d '[]' | tr , "\n" | head -c-1))
RETAINED_KEYBINDING_KEYS=()
# echo "CURRENT_KEYBINDINGS=${CURRENT_KEYBINDINGS[*]}"
for i in "${CURRENT_KEYBINDINGS[@]}"; do
    EXISTING_KEY="$(echo "$i" | tr -d "'")"
    if [[ "$EXISTING_KEY" =~ .+custom-cam-.+/$ ]]; then
        #skip over old entries
        echo "Skipping: '$EXISTING_KEY'"
    else
        #keep non-cam keybinding keys
        RETAINED_KEYBINDING_KEYS+=( "$EXISTING_KEY" )
        echo "Adding: '$EXISTING_KEY'"
    fi
done
DCONF_VALUE=$(printf ",'%s'" "${RETAINED_KEYBINDING_KEYS[@]}")
DCONF_VALUE="[${DCONF_VALUE:1}]"
RETAINED_BINDINGS=()
RETAINED_COMMANDS=()
RETAINED_NAMES=()
for i in "${RETAINED_KEYBINDING_KEYS[@]}"; do
    RETAINED_BINDINGS+=( "$(dconf read ${i}binding)" )
    RETAINED_COMMANDS+=( "$(dconf read ${i}command)" )
    RETAINED_NAMES+=( "$(dconf read ${i}name)" )
done
#reset back to defaults
dconf reset -f /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings
#re-write saved entries
COUNTER=0
for i in "${RETAINED_KEYBINDING_KEYS[@]}"; do
    dconf write ${i}binding "${RETAINED_BINDINGS[COUNTER]}"
    dconf write ${i}command "${RETAINED_COMMANDS[COUNTER]}"
    dconf write ${i}name "${RETAINED_NAMES[COUNTER]}"
    COUNTER=$((COUNTER+1))
done
dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "$DCONF_VALUE"
echo "Hotkeys Disabled"