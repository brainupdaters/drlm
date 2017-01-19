# expbackup-workflow.sh
#
# expbackup workflow for Disaster Recovery Linux Manager
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

WORKFLOW_expbackup_DESCRIPTION="export backup from DB."
WORKFLOWS=( ${WORKFLOWS[@]} expbackup )

if [ "$WORKFLOW" == "exportdr" ]; then
	# Parse options
	OPT="$(getopt -n $WORKFLOW -o "I:f:h" -l "id:,file:,help" -- "$@")"
	if (( $? != 0 )); then
			echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
			exit 1
	fi

	eval set -- "$OPT"
	while true; do
		case "$1" in
		(-I|--id)
				# We need to take the option argument
				if [ -n "$2" ]; then
					BKP_ID="$2"
				else
					echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
					exit 1
				fi
				shift
				;;
		(-f|--file)
						# We need to take the option argument
						if [ -n "$2" ]; then
							EXP_FILE_NAME="$2"
						else
							echo "$PROGRAM $WORKFLOW - $1 needs a valid argument"
							exit 1
						fi
						shift
						;;
		(-h|--help)
				expbackuphelp
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

	if [ -z "$BKP_ID" ];then
	  echo "$PROGRAM $WORKFLOW: Backup id is required."
	 	echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
	  exit 1
	fi

	if [ -z "$EXP_FILE_NAME" ];then
		echo "$PROGRAM $WORKFLOW: Output file is required."
		echo "Try \`$PROGRAM $WORKFLOW --help' for more information."
		exit 1
	fi

	WORKFLOW_expbackup () {
    		SourceStage "backup/exp"
	}

fi
