# listnetwork-workflow.sh
#
# listnetwork workflow for Disaster Recovery Linux Manager
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

WORKFLOW_listunsched_DESCRIPTION="list all the unscheduled clients."
WORKFLOWS=( ${WORKFLOWS[@]} listunsched )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} listunsched )

if [ "$WORKFLOW" == "listunsched" ]; then
	# Parse options
	if (( $? != 0 )); then
		listunschedhelp
		exit 0
	fi

	WORKFLOW_listunsched () {
		SourceStatge "client/unsched"
	}
fi
