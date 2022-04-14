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
            <th>Version</th>
            <th>Platform</th>
          </tr>
        </thead>
        <tbody v-for="session in sessions" v-bind:key="session.token">
          <tr>
            <td>{{ session.username }}</td>
            <td class="hover">
              <span class="token1">{{ session.token }}</span>
              <span class="token2">************************************</span>
            </td>
            <td>{{ session.timestamp }}</td>
            <td>{{ session.version }}</td>
            <td>{{ session.platform }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}

export default SessionsTable;
