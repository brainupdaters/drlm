var NetworksTable = {
  props: ['networks'],
  template: `
    <div class="table-responsive">
      <table class="table table-hover">
        <caption>Networks</caption>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Status</th>
            <th>ServerIP</th>
            <th>Mask</th>
            <th>NetworkIP</th>
            <th>Broadcast</th>
            <th>Gateway</th>
            <th>Interface</th>
          </tr>
        </thead>
        <tbody v-for="network in networks" v-bind:key="network.idnetwork">
          <tr>
            <td>{{ network.idnetwork }}</td>
            <td>{{ network.netname }}</td>
            <td v-if="network.active == 1">enabled</td>
            <td v-else>disabled</td>
            <td>{{ network.serverip }}</td>
            <td>{{ network.mask }}</td>
            <td>{{ network.netip }}</td>
            <td>{{ network.broadcast }}</td>
            <td>{{ network.gw }}</td>
            <td>{{ network.interface }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}

export default NetworksTable;
