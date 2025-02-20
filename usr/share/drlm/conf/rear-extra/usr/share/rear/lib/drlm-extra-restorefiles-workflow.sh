# restorefiles-workflow.sh
#
# restore workflow for Relax-and-Recover with DRLM
#
# This file is part of DRLM (Disaster Recovery Linux Manager), licensed under the GNU General
# Public License. Refer to the included COPYING for full text of license.

WORKFLOW_restorefiles_DESCRIPTION="(drlm-extra) restore backup files from DRLM" 
WORKFLOWS+=( restorefiles )
# The restorefiles workflow is a DRLM workflow for Relax-and-Recover to restore the enabled DRLM backup (and nothing else).
function WORKFLOW_restorefiles () {
    SourceStage "drlm-extra/restorefiles/RSYNC"
}

