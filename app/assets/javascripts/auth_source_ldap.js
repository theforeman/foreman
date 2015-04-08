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
function test_connection(test_connection_url){
    if($("#aid_test_connection_button_auth_source_ldap").prop('disabled') != true ){
      var serialized_form_data = $("form").serializeObject();
      serialized_form_data["_method"]="post";

      $("#aid_test_connection_button_auth_source_ldap").prop('disabled',true);

      $.ajax({
        url : test_connection_url,
        type : 'PUT',
        data : serialized_form_data,
        success :  function(data){
            $("#aid_test_connection_button_auth_source_ldap").prop('disabled',false);
            if(data.success){
              notify("<div>"+data.message+"</div>","success");
            } else{
              // In the case of error in connection to the ldap server, we are using the $.jnotify function directly instead of the wrapper "notify(item, type)" 
              // because we will need some HTML formatting for the error to be more readable
              var error_message = "<strong>"+__("Error establishing connection:")+"</strong>";
              error_message += "<br>"+ data.error_class 
              error_message += ": " + data.message;
              $.jnotify(error_message, "error", true);
            }
          }
        });
    }
}