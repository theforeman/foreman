function showSubnetIPAM(element) {
  if ($.inArray(element.val(), element.data('disable-auto-suggest-on')) !== -1)
    $('#ipam_options').hide();
  else $('#ipam_options').show();

  if ($.inArray(element.val(), element.data('enable-ipam-group-on')) >= 0)
    $('#external_ipam_options').show();
  else $('#external_ipam_options').hide();
}

function checkedRelatedRadioButton(element) {
  return $(
    'input[name=' +
      element.attr('name').replace(/(:|\.|\[|\]|,)/g, '\\$1') +
      ']:radio:checked'
  );
}

function toggleSubnetField(element, data, id) {
  if (checkedRelatedRadioButton(element).data(data)) {
    $(id)
      .closest('.form-group')
      .show();
  } else {
    $(id)
      .closest('.form-group')
      .hide();
    $(id + " option[value='']").attr('selected', 'selected');
  }
}

$(document).on('change', '#subnet_ipam', function() {
  showSubnetIPAM($(this));
});

function updateSupportedIPAM(element) {
  var supported_ipam_modes = checkedRelatedRadioButton(element).data(
    'supported_ipam_modes'
  );
  var ipam_select = $('#subnet_ipam');
  ipam_select.empty();
  for (var i = 0; i < supported_ipam_modes.length; i++) {
    var option = supported_ipam_modes[i];
    $('<option>')
      .text(option[0])
      .val(option[1])
      .appendTo(ipam_select);
  }
  ipam_select.select2();
  showSubnetIPAM(ipam_select);
}

$(document).on('click', 'input[id^=subnet_type_]', function() {
  var element = $(this);
  updateSupportedIPAM(element);
  toggleSubnetField(element, 'supports_dhcp', '#subnet_dhcp_id');
  toggleSubnetField(element, 'show_mask', '#subnet_mask');
  subnetMaskChanged($('#subnet_mask'));
  subnetCidrChanged($('#subnet_cidr'));
});

function subnetMaskChanged(field) {
  var mask = field.val();
  var cidr_field = $('#subnet_cidr');
  clearError(field);
  if (isBlank(mask)) {
    setError(field, __("can't be blank"));
    return;
  }
  if ($('input[id^=subnet_type_]:checked').val() === 'Subnet::Ipv4') {
    try {
      var cidr = ipaddr.IPv4.parse(mask).prefixLengthFromSubnetMask();
    } catch (err) {
      var cidr = '';
    }
    if (isBlank(cidr)) {
      setError(field, __('is invalid'));
    }
  } else {
    var cidr = '';
  }
  clearError(cidr_field);
  cidr_field.val(cidr);
}

function subnetCidrChanged(field) {
  var cidr = field.val();
  var mask_field = $('#subnet_mask');
  clearError(field);
  if (isBlank(cidr)) {
    setError(field, __("can't be blank"));
    return;
  }
  if ($('input[id^=subnet_type_]:checked').val() === 'Subnet::Ipv4') {
    if (!isInt(cidr) || (isInt(cidr) && (cidr < 1 || cidr > 32))) {
      var mask = '';
      setError(field, __('is invalid'));
    } else {
      var mask = cidrToNetmask(cidr);
    }
  } else {
    var mask = '';
    if (!isInt(cidr) || (isInt(cidr) && (cidr < 1 || cidr > 128))) {
      setError(field, __('is invalid'));
    }
  }
  clearError(mask_field);
  mask_field.val(mask);
}

function cidrToNetmask(bitCount) {
  var mask = [];
  for (i = 0; i < 4; i++) {
    var n = Math.min(bitCount, 8);
    mask.push(256 - Math.pow(2, 8 - n));
    bitCount -= n;
  }
  return mask.join('.');
}

function isBlank(str) {
  return !str || /^\s*$/.test(str);
}

function isInt(a) {
  return !isNaN(a) && parseInt(a) == parseFloat(a);
}

$(document).on('ContentLoad', function() {
  $('#subnet_mask').keyup(function(e) {
    subnetMaskChanged($(e.target));
  });
  $('#subnet_cidr').keyup(function(e) {
    subnetCidrChanged($(e.target));
  });
});
