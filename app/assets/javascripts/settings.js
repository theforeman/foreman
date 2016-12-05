$(document).ready(function() {
  $('.editable').editable({
    params: {
      authenticity_token: AUTH_TOKEN
    },
    error: function(response) {
      return $.parseJSON(response.responseText).errors;
    }
  });
});

function test_mail(item, user_id, url) {
  $(item).addClass("disabled");
  $('#test_indicator').show();
  var param = {id: user_id};
  $.ajax({
    url: url,
    type: 'put',
    data: param,
    success: function(result, textstatus, xhr) {
      notify("<p>" + result.message + "</p>", 'success');
    },
    error: function (xhr) {
      var error = $.parseJSON(xhr.responseText).message;
      notify("<p>" + error + "</p>", 'danger');
    },
    complete: function (result) {
      $('#test_indicator').hide();
      $(item).removeClass("disabled");
    }
  });
}
