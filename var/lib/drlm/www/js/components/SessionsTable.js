var SessionsTable = {
  props: ['sessions'],
  template: `
    <div class="table-responsive">
      <table class="table table-hover">
        <caption>Sessions</caption>
        <thead>
          <tr>
            <th>User</th>
            <th>Token</th>
            <th>Timestamp</th>
          </tr>
        </thead>
        <tbody v-for="session in sessions" v-bind:key="session.token">
          <tr>
            <td>{{ session.username }}</td>
            <td>{{ session.token }}</td>
            <td>{{ session.timestamp }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}

export default SessionsTable;
