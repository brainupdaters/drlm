# impbackup-workflow.sh
#
# impbackup workflow for Disaster Recovery Linux Manager
#
#    Disaster Recovery Linux Manager is free software; you can redistribute it
#    and/or modify it under the terms of the GNU General Public License as
#    published by the Free Software Foundation; either version 2 of the
#    License, or (at your option) any later version.

#    Disaster Recovery Linux Manager is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Disaster Recovery Linux Manager; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_impbackup_DESCRIPTION="import backup from DB."
WORKFLOWS=( ${WORKFLOWS[@]} impbackup )

if [ "$WORKFLOW" == "impbackup" ]; then
	# Parse options
	OPT="$(getopt -n $WORKFLOW -o "f:c:h" -l "file:,client:,help" -- "$@")"
	if (( $? != 0 )); then
			echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
			exit 1
	fi

	eval set -- "$OPT"
	while true; do
		case "$1" in
		(-f|--file)
				# We need to take the option argument
				if [ -n "$2" ]; then
					IMP_FILE_NAME="$2"
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
					exit 1
				fi
				shift
				;;
		(-c|--client)
				# We need to take the option argument
				if [ -n "$2" ]; then
					CLI_NAME="$2"
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
					exit 1
				fi
				shift
				;;
		(-I|--id)
				# We need to take the option argument
				if [ -n "$2" ]; then
					IMP_BKP_ID="$2"
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
					exit 1
				fi
				shift
				;;
		(-h|--help)
				impbackuphelp
				exit 0
				;;
		(--) shift; break;;
		(-*)
				echo "$PROGRAM $WORKFLOW: unrecognized option '$option'"
				echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
				exit 1
				;;
		esac
		shift
	done

	if [ -z "$CLI_NAME" ];then
	  echo "$PROGRAM $WORKFLOW: Client id is required."
	 	echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	  exit 1
	fi

	if [ -z "$IMP_FILE_NAME" ] && [ -z "$IMP_BKP_ID" ];then
		echo "$PROGRAM $WORKFLOW: Input is required."
		echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
		exit 1
	fi

	WORKFLOW_impbackup () {
    		#echo impbackup workflow
    		SourceStage "backup/imp"
	}

fi
