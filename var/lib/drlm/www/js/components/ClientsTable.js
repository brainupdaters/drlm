import ClientsTableConfigurationsList from '/js/components/ClientsTableConfigurationsList.js'

var ClientsTable = {
  components:{
    'client-configurations-list': ClientsTableConfigurationsList
  },
  props: ['clients'],
  template: `
    <div class="table-responsive">
      <table class="table table-hover" id="clients-table">
        <caption>Clients</caption>
        <thead>
          <tr>
            <th>ID</th>
            <th>Name</th>
            <th>MAC</th>
            <th>IP</th>
            <th>Network</th>
            <th>OS</th>
            <th>ReaR</th>
            <th>Token</th>
            <th>Configs</th>
          </tr>
        </thead>
        <tbody v-for="client in clients" v-bind:key="client.cli_id">
          <tr>
            <td>{{ client.cli_id }}</td>
            <td>{{ client.cli_name }}</td>
            <td>{{ client.cli_mac }}</td>
            <td>{{ client.cli_ip }}</td>
            <td>{{ client.cli_net }}</td>
            <td>{{ client.cli_os }}</td>
            <td>{{ client.cli_rear }}</td>
            <td>{{ client.cli_token }}</td>
            <td>
              <client-configurations-list
                v-for="config in client.cli_configs"
                v-bind:key="config.config_name"
                v-bind:config="config"
                v-bind:client="client"
              ></client-configurations-list>
            <td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}

export default ClientsTable;
