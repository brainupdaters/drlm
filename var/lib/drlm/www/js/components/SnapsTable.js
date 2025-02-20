var SnapsTable = {
  props: ['snaps'],
  template: `
    <div class="table-responsive">
      <table class="table table-hover">
        <caption>Snaps</caption>
        <thead>
          <tr>
            <th>IDBackup</th>
            <th>IDSnap</th>
            <th>Date</th>
            <th>Active</th>
            <th>Duration</th>
            <th>Size</th>
            <th>Info</th>
          </tr>
        </thead>
        <tbody v-for="snap in snaps" v-bind:key="snap.idsnap">
          <tr>
            <td>{{ snap.idbackup }}</td>
            <td>{{ snap.idsnap }}</td>
            <td>{{ snap.date }}</td>
            <td>{{ snap.active }}</td>
            <td>{{ snap.duration }}</td>
            <td>{{ snap.size }}</td>
            <td>{{ snap.hold == '1' ? '(H)' : '' }}{{ snap.saved_by }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}

export default SnapsTable;
