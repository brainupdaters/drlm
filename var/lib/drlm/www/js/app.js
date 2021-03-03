import AppHeader from '/js/components/AppHeader.js'
import AppBody from '/js/components/AppBody.js'
import AppFooter from '/js/components/Appfooter.js';


const vm = new Vue({
  el: '#app',
  components: {
    'app-header': AppHeader,
    'app-body': AppBody,
    'app-footer': AppFooter
  },
  data() {
    return {
      networks: 'loading',
      clients: 'loading',
      backups: 'loading',
      snaps: 'loading',
      jobs: 'loading',
      users: 'loading',
      sessions: 'loading'
    }
  },
  created() {
    this.search();
  },
  methods: {
    search: function () {
      fetch('/api/networks')
        .then(response => response.json())
        .then(json => {this.networks = json.resultList.result;});
      fetch('/api/clients')
        .then(response => response.json())
        .then(json => {this.clients = json.resultList.result;});
      fetch('/api/backups')
        .then(response => response.json())
        .then(json => {this.backups = json.resultList.result;});
      fetch('api/snaps')
        .then(response => response.json())
        .then(json => {this.snaps = json.resultList.result;});
      fetch('/api/jobs')
        .then(response => response.json())
        .then(json => {this.jobs = json.resultList.result;});
      fetch('/api/users')
        .then(response => response.json())
        .then(json => {this.users = json.resultList.result;});
      fetch('/api/sessions')
        .then(response => response.json())
        .then(json => {this.sessions = json.resultList.result;});
    }
  }
});

$.getScript("/js/AppFunctions.js", function() {
  console.log("AppFunctions.js loaded.");
});
