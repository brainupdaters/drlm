Log "####################################################"
Log "# List of Backups : 	                         "
Log "####################################################"

CLI_ID=$(get_client_id_by_name $CLI_NAME)

function check_backup_size_status() {
	size=$(awk '{print $7}')
}

function check_backup_time_status() {
	duration=$(awk '{print $6}')

	if [ "${duration:0:1}" != "-" ]; then
		separator="."
		count=0
		read -ra addr <<< "$duration"
		for i in ${addr[@]}; do
			if [ -z "$finished" ]; then
				case "$count" in
					0)
						if [ "$i" != "0h" ]; then
							echo -n "failed"
							finished=true
						fi
						;;
					1)
						if [ "$i" == "0m" ] || [ "$i" == "1m" ]; then
							echo -n "failed"
							finished=true
						elif [ "$i" == "2m" ] || [ "$i" == "3m" ]; then
							echo -n "warning"
							finished=true
						fi
						;;
				esac

				count=$((count + 1))
			fi
		done
	fi
}

function set_color() {
   color="$2"

   red="\033[0;31m"
   yellow="\033[1;33m"
   no_color="\033[0m"

   column=$(echo "$2" | cut -d" " -f $1)
   
   echo "$3" | awk '$'"$1"'="'"${!color}$column$no_color"'"'
}

if ! exist_client_name "$CLI_NAME"; then
	if [ "$CLI_NAME" == "all" ]; then
		if [ -z "$PRETTY" ]; then 
        	list_backup_all
		else
			all_backups=$(list_backup_all)
			head -n 2 <<< "$all_backups"

			while read -r line; do
				# Check time
				bkp_time_status=$(check_backup_time_status "$line")
				if [ bkp_time_status == "failed" ]; then
					line=$(set_color 6 "red" "$line")
				elif [ bkp_time_status == "warning" ]; then
					line=$(set_color 6 "yellow" "$line")
				fi

				# Check size
				bkp_size_status=$(check_backup_size_status "$line")
				if [ bkp_size_status == "failed" ]; then
					line=$(set_color 7, "red", "$line")
				elif [ bkp_size_status == "unknown" ]; then
					line=$(set_color 7, "yellow", "$line")
				fi

				echo "$line"
			done <<< $(tail -n +3 <<< "$all_backups")
		fi
	else
		printf '%25s\n' "$(tput bold)$CLI_NAME$(tput sgr0) not found in database!!"	
	fi
else
	if [ -z "$PRETTY" ]; then 
		list_backup "$CLI_NAME"
	else
			all_backups=$(list_backup "$CLI_NAME")
			head -n 2 <<< "$all_backups"

			while read -r line; do
				# Check time
				bkp_time_status=$(check_backup_time_status "$line")
				if [ bkp_time_status == "failed" ]; then
					line=$(set_color 6 "red" "$line")
				elif [ bkp_time_status == "warning" ]; then
					line=$(set_color 6 "yellow" "$line")
				fi

				# Check size
				bkp_size_status=$(check_backup_size_status "$line")
				if [ bkp_size_status == "failed" ]; then
					line=$(set_color 7, "red", "$line")
				elif [ bkp_size_status == "unknown" ]; then
					line=$(set_color 7, "yellow", "$line")
				fi

				echo "$line"
			done <<< $(tail -n +3 <<< "$all_backups")
	fi
fi
