

function rsync_port () {
    # Setting rsync port 
    echo "${RSYNC_PORT:-873}"
}

# Source() the scripts one by one:
function SourceStage () {
    local stage="$1"
    local start_SourceStage=$SECONDS
    Log "======================"
    Log "Running '$stage' stage"
    Log "======================"
    # In debug modes show what stage is run also on the user's terminal:
    test "$DEBUG" && Print "Running '$stage' stage ======================"
    # We always source scripts in the same subdirectory structure.
    # The {...,...,...} way of writing it is a shell shortcut that expands as intended.
    # The sed pipe is used to sort the scripts by their 3-digit number independent of the directory depth of the script.
    # Basically sed inserts a ! before and after the number which makes the number field nr. 2
    # when dividing lines into fields by ! so that the subsequent sort can sort by that field.
    # The final tr removes the ! to restore the original script name.
    # That code would break if ! is used in a directory name of the ReaR subdirectory structure
    # but those directories below ReaR's $SHARE_DIR/$stage directory are not named by the user
    # so that it even works when a user runs a git clone in his .../ReaRtest!/ directory.
    local scripts=( $( cd $SHARE_DIR/$stage
                 ls -d  {default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
              "$BACKUP"/{default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
              "$OUTPUT"/{default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
    "$OUTPUT"/"$BACKUP"/{default,"$ARCH","$OS","$OS_MASTER_VENDOR","$OS_MASTER_VENDOR_ARCH","$OS_MASTER_VENDOR_VERSION","$OS_VENDOR","$OS_VENDOR_ARCH","$OS_VENDOR_VERSION"}/*.sh \
                 | sed -e 's#/\([0-9][0-9][0-9]\)_#/!\1!_#g' | sort -t \! -k 2 | tr -d \! ) )
    # If no script is found, then the scripts array contains only one element '.'
    if test "$scripts" = '.' ; then
        Log "Finished running empty '$stage' stage"
        return 0
    fi

    local script_list=''
    local drlm_extra_scripts=( $( cd $SHARE_DIR/$stage
                 ls -d  "drlm-extra"/*.sh \
              "$BACKUP"/"drlm-extra"/*.sh \
              "$OUTPUT"/"drlm-extra"/*.sh \
    "$OUTPUT"/"$BACKUP"/"drlm-extra"/*.sh \
                 | sed -e 's#/\([0-9][0-9][0-9]\)_#/!\1!_#g' | sort -t \! -k 2 | tr -d \! ) )
    # If no script is found, then the scripts array contains only one element '.'
    if test "$drlm_extra_scripts" = '.' ; then
        Log "No drlm-extra scripts present in stage '$stage' to apply ..."
        script_list=( "${scripts[@]}" )
    else
        for i in "${!scripts[@]}"; do 
	    for j in "${!drlm_extra_scripts[@]}"; do 
	        if [ "$(basename ${scripts[$i]})" == "$(basename ${drlm_extra_scripts[$j]})" ]; then 
	        scripts[$i]=${drlm_extra_scripts[$j]}
	        fi
            done
        done
        script_list=( $( printf '%s\n' "${scripts[@]}" "${drlm_extra_scripts[@]}" | sed -e 's#/\([0-9][0-9][0-9]\)_#/!\1!_#g' | sort -u -t \! -k 2 | tr -d \! ) )
    fi

    local script=''
    # Source() the scripts one by one:
    for script in "${script_list[@]}" ; do
        # Tell the user about unexpected named scripts.
        # All sripts must be named with a leading three-digit number NNN_something.sh
        # otherwise the above sorting by the 3-digit number may not work as intended
        # so that sripts without leading 3-digit number are likely run in wrong order:
        grep -q '^[0-9][0-9][0-9]_' <<< $( basename $script ) || LogPrintError "Script '$script' without leading 3-digit number 'NNN_' is likely run in wrong order"
	Source $SHARE_DIR/$stage/"$script"
    done
    Log "Finished running '$stage' stage in $(( SECONDS - start_SourceStage )) seconds"
}
