function showSubnetIPAM(element) {
  if ($.inArray(element.val(), element.data('disable-auto-suggest-on')) !== -1)
    $('#ipam_options').addClass('hide');
  else
    $('#ipam_options').removeClass('hide');
}

function showSubnetDHCPProxy(element) {
  if (element.find(':selected').data('supports_dhcp')) {
    $('#dhcp-proxy-container').removeClass('hide');
  } else {
    $('#dhcp-proxy-container').addClass('hide');
    $("#subnet_dhcp_id option[value='']").attr("selected","selected");
  }
}

$(document).on('change', "#subnet_ipam", function () {
  showSubnetIPAM($(this));
});

function updateSupportedIPAM(element) {
  var supported_ipam_modes = element.find(':selected').data('supported_ipam_modes');
  var ipam_select = $('#subnet_ipam');
  ipam_select.select2('destroy').empty();
  for (var i = 0; i < supported_ipam_modes.length; i++) {
    var option = supported_ipam_modes[i];
    $('<option>').text(__(option)).val(option).appendTo(ipam_select);
  }
  $(ipam_select).select2();
  showSubnetIPAM(ipam_select);
}

$(document).on('change', "#subnet_type", function () {
  updateSupportedIPAM($(this));
  showSubnetDHCPProxy($(this));
});
