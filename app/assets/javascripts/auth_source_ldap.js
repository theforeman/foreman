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