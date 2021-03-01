var JobsTable = {
  props: ['jobs'],
  template: `
  <div class="table-responsive">
    <table class="table table-hover">
      <caption>Jobs</caption>
      <thead>
        <tr>
          <th>ID</th>
          <th>Client ID</th>
          <th>Start Date</th>
          <th>End Date</th>
          <th>Last Date</th>
          <th>Next Date</th>
          <th>Repeat</th>
          <th>Enabled</th>
          <th>Config</th>
        </tr>
      </thead>
      <tbody v-for="job in jobs" v-bind:key="job.idjob">
        <tr>
          <td>{{ job.idjob }}</td>
          <td>{{ job.clients_id }}</td>
          <td>{{ job.start_date }}</td>
          <td>{{ job.end_date }}</td>
          <td>{{ job.last_date }}</td>
          <td>{{ job.next_date }}</td>
          <td>{{ job.repeat }}</td>
          <td>{{ job.enabled }}</td>
          <td>{{ job.config }}</td>
        </tr>
      </tbody>
    </table>
  </div>
  `
}

export default JobsTable;