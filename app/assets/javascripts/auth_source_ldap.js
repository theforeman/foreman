function change_ldap_port(item) {
  var port = $('#auth_source_ldap_port');
  if (port.length > 0) {
    var port_value = port.val();
    var default_ports = port.data('default-ports');
    if (port_value != null && default_ports != null && default_ports['ldap'] != null && default_ports['ldaps'] != null) {
      if ($(item).is(':checked')) {
        if (port_value == default_ports['ldap']) {
          port.val(default_ports['ldaps']);
        }
      } else {
        if (port_value == default_ports['ldaps']) {
          port.val(default_ports['ldap']);
        }
      }
    }
  }
}