document.getElementById("logout-button").onclick = function() {
  fetch('/logout',{method: 'POST'});
  location.href = "/";
};
