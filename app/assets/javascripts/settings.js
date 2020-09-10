$(document).ready(function() {
  $('.editable').editable({
    params: {
      authenticity_token: AUTH_TOKEN,
    },
    error: function(response) {
      return $.parseJSON(response.responseText).errors;
    },
  });
});
