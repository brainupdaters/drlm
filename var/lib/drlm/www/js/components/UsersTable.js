var UsersTable = {
  props: ['users'],
  template: `
    <div class="table-responsive">
      <table class="table table-hover">
        <caption>Users</caption>
        <thead>
          <tr>
            <th>User</th>
            <th>Password</th>
          </tr>
        </thead>
        <tbody v-for="user in users" v-bind:key="user.user_name">
          <tr>
            <td>{{ user.user_name }}</td>
            <td class="hover">
              <span class="token1">{{ user.user_password }}</span>
              <span class="token2">********************************</span>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  `
}

export default UsersTable;
