# help-workflow.sh
#
# help workflow for Disater Recovery Linux Server
#
#  Disaster Recovery Linux Manager is free software; you can redistribute it 
#  and/or modify it under the terms of the GNU General Public License as 
#  published by the Free Software Foundation; either version 2 of the 
#  License, or (at your option) any later version.

#  Disaster Recovery Linux Manager is distributed in the hope that it will be
#  useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.

#  You should have received a copy of the GNU General Public License
#  along with Disaster Recovery Linux Manager; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

#LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} help )
WORKFLOW_help () {
	cat <<EOF
Usage: $PROGRAM [-dDsSvV] COMMAND [-- ARGS...]

$PRODUCT comes with ABSOLUTELY NO WARRANTY; for details 
see The GNU General Public License at: http://www.gnu.org/licenses/gpl.html

Available options:
 -d           debug mode; log debug messages
 -D           debugscript mode; log every function call
 -s           simulation mode; show what scripts drlm would include
 -S           step-by-step mode; acknowledge each script individually
 -v           verbose mode; show more output
 -V           version information

List of commands:
$(
	for workflow in ${WORKFLOWS[@]} ; do
		description=WORKFLOW_${workflow}_DESCRIPTION
		if [[ "${!description}" ]]; then
			if [[ -z "$RECOVERY_MODE" && "$workflow" != "recover" ]]; then
				printf " %-16s%s\n" $workflow "${!description}"
			elif [[ "$RECOVERY_MODE" && "$workflow" == "recover" ]]; then
				printf " %-16s%s\n" $workflow "${!description}"
			fi
		fi
	done
)

EOF

if [[ -z "$VERBOSE" ]]; then
	echo "Use 'drlm COMMAND --help' for more advanced commands."
fi

	EXIT_CODE=1
}
