# delbackup-workflow.sh
#
# delbackup workflow for Disaster Recovery Linux Server
#
#    Disaster Recovery Linux Server is free software; you can redistribute it 
#    and/or modify it under the terms of the GNU General Public License as 
#    published by the Free Software Foundation; either version 2 of the 
#    License, or (at your option) any later version.

#    Disaster Recovery Linux Server is distributed in the hope that it will be
#    useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with Disaster Recovery Linux Server; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_delbackup_DESCRIPTION="delete client backup and unregister from database"
WORKFLOWS=( ${WORKFLOWS[@]} delbackup )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} delbackup )

if [ "$WORKFLOW" == "delbackup" ]; then 
    echo "" > /dev/null
fi

WORKFLOW_delbackup () {
    echo delbackup workflow
    SourceStage "backup/del"
}

#1	Check backup in server database
#2	Remove backup files and drop form database
#3      ...
#4	...
