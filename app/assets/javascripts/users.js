function test_mail(item, id, url) {
  $(item).addClass("disabled");
  $('#test_indicator').show();
  var email = $("#user_mail").val();
  var param = {user_email: email};
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
  })
}
