# addbackup-workflow.sh
#
# addbackup workflow for Disaster Recovery Linux Manager
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

WORKFLOW_addbackup_DESCRIPTION="register backup to database"
WORKFLOWS=( ${WORKFLOWS[@]} addbackup )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} addbackup )

#if [ "$WORKFLOW" == "addbackup" ]; then 
    echo "" > /dev/null
#fi

WORKFLOW_addbackup () {
#    echo addbackup workflow
    SourceStage "backup/add"
}

#1	Register manual backup to database
#2	...
#3	...
#4	...
