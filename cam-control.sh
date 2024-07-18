#/bin/bash
set -e
set +u

#example control commands via uvcdynctrl
# uvcdynctrl -l
# uvcdynctrl -cv -d /dev/video2
# uvcdynctrl -d /dev/video4 -s 'Zoom, Absolute' 200
# uvcdynctrl -d /dev/video4 -g 'Zoom, Absolute'

SCRIPT_PATH="$(readlink -f -- "$0")"
SCRIPT_DIR="$(dirname -- "$(readlink -f -- "$0")")" #no trailing slash
CONFIG_DIR="$(readlink -f ~/.local/share/cam-control)"

#preflight
if ! command -v uvcdynctrl &> /dev/null; then
    >&2 echo "Command 'uvcdynctrl' could not be found."
    >&2 echo "Please install uvcdynctrl before using this script."
    exit 1
fi

#functions

load_settings () {
	mkdir -p "$CONFIG_DIR"
	if [ ! -f "$CONFIG_DIR/settings" ]; then
		#create a cam control config file
		cat <<EOF >> "$CONFIG_DIR/settings"
Active Camera

Camera List

EOF
	else
		#load the current control file
		FILE_LINES=()
		readarray -t FILE_LINES < "$CONFIG_DIR/settings"
		FILE_SECTION=
		for i in "${FILE_LINES[@]}"; do
			if [[ -n "$i" ]]; then #skip blank lines
				if [[ "$FILE_SECTION" == "Active Camera" ]] && [[ "$i" != "Camera List" ]]; then
					DEVICE="$i"
					FILE_SECTION=
				elif [[ "$FILE_SECTION" == "Camera List" ]]; then
					DEVICE_LIST+=( "$i" )
				fi
				#check if we're in a new section
				if [[ "$i" == "Active Camera" ]] || [[ "$i" == "Camera List" ]]; then
					FILE_SECTION="$i"
				fi
			fi
		done
	fi 
}

save_settings () {
		cat <<EOF > "$CONFIG_DIR/settings"
Active Camera
$DEVICE

Camera List
$(printf "%s\n" "${DEVICE_LIST[@]}")
EOF
}

device_list_indexof() {
	local -n result=$2
	result=-1
	for i in "${!DEVICE_LIST[@]}"; do
		if [ "${DEVICE_LIST[$i]}" == "$1" ]; then
			result=$i
			break
		fi 
	done
}

#configure
DEVICE=
DEVICE_LIST=()
load_settings

#check first arg for device, "add", "remove", "set", "list", "next", "prev", "first", "last"
if [[ "$1" == "set" ]]; then
	if [[ -z "$2" ]]; then
		>&2 echo "Please specify the device to be set as active. e.g. /dev/video0"
		exit 2;
	fi
	DEVICE="$2"
	save_settings
	echo "Device $2 set."
	exit 0
elif [[ "$1" == "add" ]]; then
	if [[ -z "$2" ]]; then
		>&2 echo "Please specify the device to be added to the list. e.g. /dev/video0"
		exit 2;
	fi
	if [[ "${DEVICE_LIST[@]}" =~ "$2" ]]; then
		echo "Device $2 already exists."
	else
		DEVICE_LIST+=( "$2" )
		save_settings
		echo "Device $2 added."
	fi
	exit 0
elif [[ "$1" == "remove" ]]; then
	if [[ -z "$2" ]]; then
		>&2 echo "Please specify the device to be removed from the list. e.g. /dev/video0"
		exit 2;
	fi
	if [[ "${DEVICE_LIST[@]}" =~ "$2" ]]; then
		for i in "${!DEVICE_LIST[@]}"; do
			if [ "${DEVICE_LIST[$i]}" == "$2" ]; then
				unset DEVICE_LIST[$i]
			fi 
		done
		save_settings
		echo "Device $2 removed."
	else
		echo "Device $2 was not found in the list."
	fi
	exit 0
elif [[ "$1" == "list" ]]; then
	echo "Default Device: $DEVICE"
	echo "Device List:"
	COUNTER=1
	for d in "${DEVICE_LIST[@]}"; do
		echo "$COUNTER. $d"
		COUNTER=$((COUNTER+1))
	done
	exit 0

elif [[ "$1" == "prev" ]]; then
	if [[ ${#DEVICE_LIST[@]} -eq 0 ]]; then 
		echo "There are no devices in the list. Use the add command to add a device."
		exit 2
	fi
	CURRENT_DEVICE_INDEX=0
	device_list_indexof "$DEVICE" CURRENT_DEVICE_INDEX
	if [[ $CURRENT_DEVICE_INDEX -gt 0 ]]; then 
		DEVICE="${DEVICE_LIST[$((CURRENT_DEVICE_INDEX-1))]}"
	else
		DEVICE="${DEVICE_LIST[${#DEVICE_LIST[@]}-1]}"
	fi
	echo "Device $DEVICE set."
	save_settings
	exit 0
elif [[ "$1" == "next" ]]; then
	if [[ ${#DEVICE_LIST[@]} -eq 0 ]]; then 
		echo "There are no devices in the list. Use the add command to add a device."
		exit 2
	fi
	CURRENT_DEVICE_INDEX=0
	device_list_indexof "$DEVICE" CURRENT_DEVICE_INDEX
	if [[ $CURRENT_DEVICE_INDEX -lt ${#DEVICE_LIST[@]}-1 ]]; then 
		DEVICE="${DEVICE_LIST[$((CURRENT_DEVICE_INDEX+1))]}"
	else
		DEVICE="${DEVICE_LIST[0]}"
	fi
	echo "Device $DEVICE set."
	save_settings
	exit 0
elif [[ "$1" == "first" ]]; then
	if [[ ${#DEVICE_LIST[@]} -eq 0 ]]; then 
		echo "There are no devices in the list. Use the add command to add a device."
		exit 2
	fi
	DEVICE="${DEVICE_LIST[0]}"
	save_settings
	echo "Device $DEVICE set."
	exit 0
elif [[ "$1" == "last" ]]; then
	if [[ ${#DEVICE_LIST[@]} -eq 0 ]]; then 
		echo "There are no devices in the list. Use the add command to add a device."
		exit 2
	fi
	DEVICE="${DEVICE_LIST[${#DEVICE_LIST[@]} - 1]}"
	save_settings
	echo "Device $DEVICE set."
	exit 0
elif [[ "$1" =~ ^/.+ ]]; then
	DEVICE="$1"
	echo "Active device: $1"
elif [[ -n "$DEVICE" ]]; then
	echo "Active device: $DEVICE (default)"
fi

if [[ -z "$DEVICE" ]]; then
	>&2 echo "Device in argument 1 was not specified and no default device is set."
	>&2 echo "Please specify the device as the first argument. e.g. /dev/video0"
	>&2 echo "Or set the default device with the 'set' command."
	exit 2;
fi

CONTROLS=()
VALUES=()
COUNTER=0
ARG_OFFSET=0
if [[ "$1" =~ ^/.+ ]]; then
	ARG_OFFSET=1
fi
for argument in "$@"; do
    if [[ $COUNTER -ge $ARG_OFFSET ]]; then
	    if [[ $((COUNTER % 2)) -eq $ARG_OFFSET ]]; then
	    	CONTROLS+=( "$argument" )
	    else
	    	VALUES+=( "$argument" )
	    fi
    fi
    COUNTER=$((COUNTER+1))
done
# echo Controls: ${CONTROLS[*]}
# echo Values: ${VALUES[*]}
if [[ ${#CONTROLS[@]} -eq 0 ]]; then
	>&2 echo "Invalid number of control and value arguments."
	exit 1
fi
if [[ ${#CONTROLS[@]} -ne ${#VALUES[@]} ]]; then
	>&2 echo "Invalid number of control and value arguments."
	>&2 echo "Check that each control argument is followed by a value."
	exit 1
fi
COUNTER=0
for CONTROL in "${CONTROLS[@]}"; do
	VALUE=${VALUES[$COUNTER]}
	CURRENT_VALUE=$(uvcdynctrl -d "$DEVICE" -g "$CONTROL" 2> /dev/null)
	echo "Device: $DEVICE; Control: $CONTROL; Current Value: $CURRENT_VALUE; Value: $VALUE"
	#Check for relative values.
	if [[ "$VALUE" =~ ^\+.* ]]; then
		VALUE=`expr $CURRENT_VALUE + $(echo $VALUE | cut -c 2-)`
	elif [[ "$VALUE" =~ ^\-.* ]]; then
		VALUE=`expr $CURRENT_VALUE - $(echo $VALUE | cut -c 2-)`
	fi
	#Make the call to set the camera.
	if [[ "$VALUE" =~ ^\-.* ]]; then
		uvcdynctrl -d "$DEVICE" -s "$CONTROL" -- "$VALUE"
	else
		uvcdynctrl -d "$DEVICE" -s "$CONTROL" "$VALUE"
	fi
	COUNTER=$((COUNTER+1))
done
exit 0
