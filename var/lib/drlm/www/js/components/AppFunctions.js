document.getElementById("logout-button").onclick = function(event) {
  $.ajax({
    type: 'POST',
    url: '/logout',
    cache: false,
    success: function () {
      location.href = "/signin";
    },
  })
  event.preventDefault();
};
