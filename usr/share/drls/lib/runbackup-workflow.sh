# runbackup-workflow.sh
#
# runbackup workflow for Disaster Recovery Linux Server
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
#    along with Relax-and-Recover; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
#

WORKFLOW_runbackup_DESCRIPTION="run client backup and register to database"
WORKFLOWS=( ${WORKFLOWS[@]} runbackup )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} runbackup )
WORKFLOW_runbackup () {
    echo runbackup workflow
    SourceStage "backup/run"
}

#1	Check if client reqs. to backup (if is registered and conectivity)
#2	Check Limit Number of client backups in server and prepare backup 
#3	Run backup and report success or errors 
#4	Register Backup to drls backups database
#5      ...
#6	...
#7	...
