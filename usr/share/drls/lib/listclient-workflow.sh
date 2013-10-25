# listclient-workflow.sh
#
# listclient workflow for Disaster Recovery Linux Server
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

WORKFLOW_listclient_DESCRIPTION="list clients"
WORKFLOWS=( ${WORKFLOWS[@]} listclient )
LOCKLESS_WORKFLOWS=( ${LOCKLESS_WORKFLOWS[@]} listclient )
WORKFLOW_listclient () {
    echo listclient workflow
    SourceStage "client/list"
}

#1	
#2	
