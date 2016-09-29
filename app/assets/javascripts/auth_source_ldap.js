function test_connection(item, url) {
  $('#test_connection_indicator').show();
  $(item).addClass("disabled");
  var data = $("form").serialize();
  $.ajax({
    url: url,
    type: 'put',
    data: data,
    success: function (result, textstatus, xhr) {
      notify("<p>" + result.message + "</p>", 'success');
    },
    error: function (xhr) {
      var error = $.parseJSON(xhr.responseText).message;
      notify("<p>" + error + "</p>", 'danger');
    },
    complete: function (result) {
      $('#test_connection_indicator').hide();
      $(item).removeClass("disabled");
    }
  })
}

function change_ldap_port(item) {
  var port = $('#auth_source_ldap_port');
  if (port.length > 0) {
    var value = port.val();
    var default_ports = port.data('default-ports');
    if (value != null && default_ports != null && default_ports['ldap'] != null && default_ports['ldaps'] != null) {
      if ($(item).is(':checked')) {
        if (value == default_ports['ldap']) {
          port.val(default_ports['ldaps']);
        }
      } else {
        if (value == default_ports['ldaps']) {
          port.val(default_ports['ldap']);
        }
      }
    }
  }
}
