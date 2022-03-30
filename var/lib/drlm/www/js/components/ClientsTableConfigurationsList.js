var ClientsTableConfigurationsList = {
  props: ['config','client'],
  template: `
    <div class="client-config">
      <li>
        <a href="#" data-bs-toggle="modal" :data-bs-target="'#demo' + client.cli_id + config.config_name" v-on:click="update_client_config(client.cli_id,config.config_name)"> {{ config.config_name }} </a>
        <div class="modal fade" :id="'demo' + client.cli_id + config.config_name" tabindex="-1" aria-hidden="true">
          <div class="modal-dialog modal-xl">
            <div class="modal-content">
              <div class="modal-header">
                <h6 class="modal-title"><strong>Client:</strong><em> {{ client.cli_name }} </em> | <strong>Backup Configuration:</strong> <em>{{ config.config_name }} </em></h6>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
              </div>
              <div class="modal-body" style="white-space: pre-line"><code>{{ config.config_content }}</code></div>
            </div>
          </div>
        </div>
      </li>
    </div>
  `,
  methods: {
    update_client_config: async function(client, config){
      const response = await fetch("/api/clients/"+client+"/configs/"+config);
      const data = await response.json();
      this.config.config_content = data.result.config_content
    }
  }
}

export default ClientsTableConfigurationsList;
