$(document).ready(function() {
  $('.editable').editable({
    error: function(response) {
      return $.parseJSON(response.responseText).errors;
    }
  });
});
