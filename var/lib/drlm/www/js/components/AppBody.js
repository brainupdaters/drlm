import NetworksTable from './NetworksTable.js'
import ClientsTable from './ClientsTable.js'
import BackupsTable from '/js/components/BackupsTable.js'
import SnapsTable from './SnapsTable.js'
import JobsTable from './JobsTable.js'
import UsersTable from './UsersTable.js'
import SessionsTable from './SessionsTable.js'

var AppBody = {
  components:{
    'clients-table': ClientsTable,
    'networks-table': NetworksTable,
    'backups-table': BackupsTable,
    'snaps-table': SnapsTable,
    'jobs-table': JobsTable,
    'users-table': UsersTable,
    'sessions-table': SessionsTable
  },
  props: ['networks', 'clients', 'backups', 'snaps', 'jobs', 'users', 'sessions'],
  template: `
    <div>
      <networks-table
        v-bind:networks="networks"
      ></networks-table>

      <clients-table
        v-bind:clients="clients"
      ></clients-table>

      <backups-table
        v-bind:backups="backups"
      ></backups-table>

      <snaps-table
        v-bind:snaps="snaps"
      ></snaps-table>

      <jobs-table
        v-bind:jobs="jobs"
      ></jobs-table>

      <div class="row">
        <div class="col-lg-5">
          <users-table
            v-bind:users="users"
          ></users-table>
        </div>
        <div class="col-lg-7">
          <sessions-table
            v-bind:sessions="sessions"
          ></sessions-table>
        </div>
      </div>
    </div>
  `
}

export default AppBody;
