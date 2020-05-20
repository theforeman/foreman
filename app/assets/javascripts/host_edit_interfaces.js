$(document).ready(function() {
  $('#host_name').select();
  $('#host_name').focus();
});

function remove_interface(interface_id) {
  $('#interface' + interface_id).remove();
  $('#interfaceHidden' + interface_id + ' .destroyFlag').val(1);
}

function edit_interface(interface_id) {
  if (interface_id == null) form = get_interface_template_clone();
  else form = $('#interfaces #interfaceHidden' + interface_id).clone(true);
  show_interface_modal(form);
}

function show_interface_modal(modal_content) {
  var modal_window = $('#interfaceModal');
  var interface_id = modal_content.data('interface-id');

  modal_window.data('current-id', interface_id);

  var identifier = modal_content.find('.interface_identifier').val();

  modal_window.find('.modal-body').html('');
  modal_window.find('.modal-body').append(modal_content.contents());
  modal_window
    .find('.modal-title')
    .text(__('Interface') + ' ' + String(identifier));
  modal_window.modal({ show: true });

  modal_window.find('a[rel="popover-modal"]').popover();
  activate_select2(modal_window);
}

function save_interface_modal() {
  var modal_window = $('#interfaceModal');
  var interface_id = modal_window.data('current-id');

  //destroy ui tools so when opening the modal again they will show correctly
  modal_window.find('a[rel="popover-modal"]').popover('destroy');
  modal_window.find('select').select2('destroy');

  // mark the selected values to preserve them for form hiding
  preserve_selected_options(modal_window);

  var modal_form = modal_window.find('.modal-body').contents();
  if (modal_form.find('.interface_primary').is(':checked')) {
    $('#interfaceForms .interface_primary:checked').attr('checked', false);
  }
  if (modal_form.find('.interface_provision').is(':checked')) {
    $('#interfaceForms .interface_provision:checked').attr('checked', false);
  }

  var interface_hidden = get_interface_hidden(interface_id);
  interface_hidden.html('');
  interface_hidden.append(modal_form);

  close_interface_modal();
  sync_primary_name(false);
  update_interface_table();
  update_fqdn();
}

function sync_primary_name(ovewrite_blank) {
  var nic_name = primary_nic_form().find('.interface_name');
  var host_name = $('#host_name');

  if (ovewrite_blank && nic_name.val().length == 0)
    nic_name.val(host_name.val());
  else host_name.val(nic_name.val());
}

function close_interface_modal() {
  var modal_window = $('#interfaceModal');

  modal_window.modal('hide');
  modal_window.removeData('current-id');
  modal_window.find('.modal-body').html('');
}

function get_interface_template_clone() {
  var content = $('#interfaces .interfaces_fields_template').html();
  var interface_id = new Date().getTime();

  content = fix_template_names(content, 'interfaces', interface_id);

  var hidden = $(content);

  $('#interfaceForms')
    .closest('form')
    .trigger({ type: 'nested:fieldAdded', field: hidden });
  $('a[rel="popover"]').popover();
  $('a[rel="twipsy"]').tooltip();

  hidden.attr('id', 'interfaceHidden' + interface_id);
  hidden.data('interface-id', interface_id);
  hidden.find('.destroyFlag').val(0);

  return hidden;
}

function get_interface_row(interface_id) {
  var interface_row = $('#interface' + interface_id);
  if (interface_row.length == 0) {
    interface_row = $('#interfaceTemplate').clone(true);
    interface_row.attr('id', 'interface' + interface_id);
    interface_row.data('interface-id', interface_id);

    interface_row.find('.showModal').click(function() {
      edit_interface(interface_id);
      return false;
    });

    interface_row.find('.removeInterface').click(function() {
      remove_interface(interface_id);
      return false;
    });

    interface_row.show();
    interface_row.insertBefore('#interfaceTemplate');
  }
  return interface_row;
}

function get_interface_hidden(interface_id) {
  var interface_hidden = $('#interfaceHidden' + interface_id);
  if (interface_hidden.length == 0) {
    interface_hidden = $('<div></div>');
    interface_hidden.attr('class', 'hidden');
    interface_hidden.attr('id', 'interfaceHidden' + interface_id);
    interface_hidden.data('interface-id', interface_id);

    $('#interfaceForms').append(interface_hidden);
  }
  return interface_hidden;
}

function fqdn(name, domain) {
  if (!name || !domain) return '';
  else return name + '.' + domain;
}

function update_interface_row(row, interface_form) {
  var has_errors = interface_form.find('.has-error').length > 0;
  row.toggleClass('has-error', has_errors);

  var virtual = interface_form.find('.virtual').is(':checked');
  var attached = interface_form.find('.attached').val();

  var type = interface_form.find('.interface_type option:selected').text();
  type += '<div class="additional-info">';
  type += nic_info(interface_form);
  type += '</div>';
  row.find('.type').html(type);

  row
    .find('.identifier')
    .text(interface_form.find('.interface_identifier').val());
  row.find('.mac').text(interface_form.find('.interface_mac').val());
  row.find('.ip').text(interface_form.find('.interface_ip').val());
  row.find('.ip6').text(interface_form.find('.interface_ip6').val());

  var flags = '',
    primary_class = '',
    provision_class = '',
    managed_class = '';

  if (interface_form.find('.interface_primary').is(':checked'))
    primary_class = 'active';

  if (interface_form.find('.interface_provision').is(':checked'))
    provision_class = 'active';

  if (interface_form.find('.interface_managed').is(':checked'))
    managed_class = 'active'

  if (primary_class == '' && provision_class == '')
    row.find('.removeInterface').removeAttr('disabled');
  else row.find('.removeInterface').attr('disabled', 'disabled');

  flags +=
    '<i class="glyphicon glyphicon glyphicon-tag primary-flag ' +
    primary_class +
    '" title="" data-original-title="' +
    __('Primary') +
    '"></i>';
  flags +=
    '<i class="glyphicon glyphicon glyphicon-hdd provision-flag ' +
    provision_class +
    '" title="" data-original-title="' +
    __('Provisioning') +
    '"></i>';
  flags +=
    '<i class="glyphicon glyphicon glyphicon-home managed-flag ' +
    managed_class +
    '" title="" data-original-title="' +
    __('Managed') +
    '"></i>';

  row.find('.flags').html(flags);

  row
    .find('.fqdn')
    .text(
      fqdn(
        interface_form.find('.interface_name').val(),
        interface_form.find('.interface_domain option:selected').text()
      )
    );

  $('.primary-flag').tooltip();
  $('.provision-flag').tooltip();
  $('.managed-flag').tooltip();
}

function update_interface_table() {
  $.each(active_interface_forms(), function(index, form) {
    var interface_id = $(form).data('interface-id');

    var interface_row = get_interface_row(interface_id);
    var interface_hidden = get_interface_hidden(interface_id);

    update_interface_row(interface_row, interface_hidden);
  });
}

function active_interface_forms() {
  return $.grep($('#interfaceForms > div'), function(f) {
    var flag = $(f)
      .find('.destroyFlag')
      .val();
    return flag == false || flag == undefined;
  });
}

function confirm_flag_change(element, element_selector, massage) {
  if (!$(element).is(':checked')) return;

  var this_interface_id = $('#interfaceModal').data('current-id');

  var other_selected;
  other_selected = $(active_interface_forms())
    .find(element_selector + ':checked')
    .closest('fieldset');
  other_selected = $.grep(other_selected, function(i) {
    return (
      $(i)
        .parent()
        .data('interface-id') != this_interface_id
    );
  });

  if (other_selected.length > 0) {
    return confirm(massage);
  }
}

function primary_nic_form() {
  return $(active_interface_forms())
    .find('.interface_primary:checked')
    .closest('fieldset');
}

$(document).on('click', '.interface_primary', function() {
  var confirmed = confirm_flag_change(
    this,
    '.interface_primary',
    __(
      'Some other interface is already set as primary. Are you sure you want to use this one instead?'
    )
  );

  if (confirmed) {
    // preset dns name from host name if it's blank
    var name = $(this)
      .closest('fieldset')
      .find('.interface_name');
    if (name.val().length == 0) name.val($('#host_name').val());
  }

  return confirmed;
});

$(document).on('click', '.interface_provision', function() {
  return confirm_flag_change(
    this,
    '.interface_provision',
    __(
      'Some other interface is already set as provisioning. Are you sure you want to use this one instead?'
    )
  );
});

$(document).on('change', '#host_name', function() {
  // copy host name to the primary interface's name
  primary_nic_form()
    .find('.interface_name')
    .val($(this).val());
  update_interface_table();
  update_fqdn();
});

$(document).on('click', '.primary-flag', function() {
  var interface_id = $(this)
    .closest('tr')
    .data('interface-id');

  $('#interfaceForms .interface_primary:checked').prop('checked', false);
  get_interface_hidden(interface_id)
    .find('.interface_primary')
    .prop('checked', true);

  sync_primary_name(true);
  update_interface_table();
  update_fqdn();
});

$(document).on('click', '.provision-flag', function() {
  var interface_id = $(this)
    .closest('tr')
    .data('interface-id');

  $('#interfaceForms .interface_provision:checked').prop('checked', false);
  get_interface_hidden(interface_id)
    .find('.interface_provision')
    .prop('checked', true);

  update_interface_table();
});

$(document).on('click', '.managed-flag', function() {
  var interface_id = $(this)
    .closest('tr')
    .data('interface-id');

  var managedCheckbox = get_interface_hidden(interface_id)
    .find('.interface_managed');

  var isChecked = $(managedCheckbox).prop('checked');

  $(managedCheckbox).prop('checked', !isChecked);

  update_interface_table();
});

var providerSpecificNICInfo = null;

function nic_info(form) {
  var info = '';
  var virtual_types = ['Nic::Bond', 'Nic::Bridge'];
  if (
    form.find('.virtual').is(':checked') ||
    virtual_types.indexOf(form.find('select.interface_type').val()) >= 0
  ) {
    // common virtual
    var attached = form.find('.attached').val();
    if (attached != '')
      info = tfm.i18n.sprintf(__('virtual attached to %s'), attached);
    else info = __('virtual');
  } else {
    // provider specific
    if (typeof providerSpecificNICInfo == 'function')
      info = providerSpecificNICInfo(form);
    else info = __('physical');
  }
  return info;
}

$(document).on('change', '.compute_attributes', function() {
  // remove "from profile" note if any of the fields changes
  $(this)
    .closest('.compute_attributes')
    .find('.profile')
    .html('');
});

$(document).on('change', '.virtual', function() {
  var is_virtual = $(this).is(':checked');

  $(this)
    .closest('fieldset')
    .find('.virtual_form')
    .toggle(is_virtual);
  $(this)
    .closest('fieldset')
    .find('.compute_attributes')
    .toggle(!is_virtual);
});

function update_fqdn() {
  var host_name = $('#host_name').val();
  var domain_name = primary_nic_form()
    .find('.interface_domain option:selected')
    .text();
  var pathname = window.location.pathname;
  var name = fqdn(host_name, domain_name);
  if (name.length > 0 && pathname === tfm.nav.foremanUrl('/hosts/new')) {
    name = __('Create Host') + ' | ' + name;
    tfm.store.dispatch('updateBreadcrumbTitle', name);
  }
}

$(document).on('change', '.interface_mac', function(event) {
  if (
    event.target.id ==
    $('#interfaceModal')
      .find('.interface_mac')
      .attr('id')
  ) {
    var interface = $('#interfaceModal').find('.interface_mac');
    var mac = interface.val();
    var baseurl = interface.attr('data-url');
    $.ajax({
      type: 'GET',
      url: baseurl + '?mac=' + mac,
      success: function(response, status, xhr) {
        if ($('#host_name').val() == '') $('#host_name').val(response.name);
        if (
          $('#interfaceModal')
            .find('.interface_name')
            .val() == ''
        )
          $('#interfaceModal')
            .find('.interface_name')
            .val(response.name);
      },
    });
  }
});
