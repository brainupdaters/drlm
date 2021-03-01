var NetworksTable = {
  props: ['networks'],
  template: `
    <div class="table-responsive">
      <table class="table table-hover">
        <caption>Networks</caption>
        <thead>
          <tr>
            <th>ID</th>
            <th>NetworkIP</th>
            <th>Mask</th>
            <th>Gateway</th>
            <th>Broadcast</th>
            <th>ServerIP</th>
            <th>Name</th>
          </tr>
        </thead>
        <tbody v-for="network in networks" v-bind:key="network.idnetwork">
          <tr>
            <td>{{ network.idnetwork }}</td>
            <td>{{ network.netip }}</td>
            <td>{{ network.mask }}</td>
            <td>{{ network.gw }}</td>
            <td>{{ network.broadcast }}</td>
            <td>{{ network.serverip }}</td>
            <td>{{ network.netname }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}

export default NetworksTable;
