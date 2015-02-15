

function remove_interface(interface_id) {
  $('#interface'+interface_id).remove();
  $('#interfaceHidden'+interface_id+' .destroyFlag').val(1);
}

function edit_interface(interface_id) {
  if (interface_id == null)
    form = get_interface_template_clone();
  else
    form = $('#interfaces #interfaceHidden'+interface_id).clone(true);

  show_interface_modal(form);
}

function show_interface_modal(modal_content) {
  var modal_window = $('#interfaceModal');
  var interface_id = modal_content.data('interface-id');

  modal_window.data('current-id', interface_id);

  var identifier = modal_content.find('.interface_identifier').val();


  modal_window.find('.modal-body').html('');
  modal_window.find('.modal-body').append(modal_content.contents());
  modal_window.find('.modal-title').html(__('Interface') + ' ' + String(identifier));
  modal_window.modal({'show': true});

  modal_window.find('a[rel="popover-modal"]').popover({html: true});
}

function save_interface_modal() {
  var modal_window = $('#interfaceModal');
  var interface_id = modal_window.data('current-id');

  var modal_form = modal_window.find('.modal-body').contents();
  if (modal_form.find('.interface_primary').is(':checked')) {
    $('#interfaceForms .interface_primary:checked').attr("checked", false);
  }
  if (modal_form.find('.interface_provision').is(':checked')) {
    $('#interfaceForms .interface_provision:checked').attr("checked", false);
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

  if (ovewrite_blank && (nic_name.val().length == 0))
    nic_name.val(host_name.val());
  else
    host_name.val(nic_name.val());
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

  $('#interfaceForms').closest("form").trigger({type: 'nested:fieldAdded', field: hidden});
  $('a[rel="popover"]').popover({html: true});
  $('a[rel="twipsy"]').tooltip();

  hidden.attr('id', 'interfaceHidden'+interface_id);
  hidden.data('interface-id', interface_id);
  hidden.find('.destroyFlag').val(0);

  return hidden;
}

function get_interface_row(interface_id) {
  var interface_row = $('#interface'+interface_id);
  if ( interface_row.length == 0) {
    interface_row = $('#interfaceTemplate').clone(true);
    interface_row.attr('id', 'interface'+interface_id);
    interface_row.data('interface-id', interface_id);

    interface_row.find('.showModal').click( function(){
      edit_interface(interface_id);
      return false;
    });

    interface_row.find('.removeInterface').click( function(){
      remove_interface(interface_id);
      return false;
    });

    interface_row.show();
    interface_row.insertBefore('#interfaceTemplate');
  }
  return interface_row;
}

function get_interface_hidden(interface_id) {
  var interface_hidden = $('#interfaceHidden'+interface_id);
  if ( interface_hidden.length == 0) {

    interface_hidden = $('<div></div>');
    interface_hidden.attr('class', 'hidden');
    interface_hidden.attr('id', 'interfaceHidden'+interface_id);
    interface_hidden.data('interface-id', interface_id);

    $('#interfaceForms').append(interface_hidden);
  }
  return interface_hidden;
}

function fqdn(name, domain) {
  if (!name || !domain)
    return ""
  else
    return name + '.' + domain;
}

function update_interface_row(row, interface_form) {
  row.find('.type').html(interface_form.find('.interface_type option:selected').text());
  row.find('.identifier').html(interface_form.find('.interface_identifier').val());
  row.find('.mac').html(interface_form.find('.interface_mac').val());
  row.find('.ip').html(interface_form.find('.interface_ip').val());

  var flags = '', primary_class = '', provision_class = '';
  if (interface_form.find('.interface_primary').is(':checked'))
    primary_class = 'active'

  if (interface_form.find('.interface_provision').is(':checked'))
    provision_class = 'active'

  if (primary_class == '' && provision_class == '')
    row.find('.removeInterface').removeClass('disabled');
  else
    row.find('.removeInterface').addClass('disabled');

  flags += '<i class="glyphicon glyphicon glyphicon-tag primary-flag '+ primary_class +'" title="" data-original-title="'+ __('Primary') +'"></i>';
  flags += '<i class="glyphicon glyphicon glyphicon-hdd provision-flag '+ provision_class +'" title="" data-original-title="'+ __('Provisioning') +'"></i>';

  row.find('.flags').html(flags);

  row.find('.fqdn').html(fqdn(
    interface_form.find('.interface_name').val(),
    interface_form.find('.interface_domain option:selected').text()
  ));

  $('.primary-flag').tooltip();
  $('.provision-flag').tooltip();
}

function update_interface_table() {
  $.each(active_interface_forms(), function(index, form) {
    var interface_id = $(form).data('interface-id');

    var interface_row = get_interface_row(interface_id);
    var interface_hidden = get_interface_hidden(interface_id)

    update_interface_row(interface_row, interface_hidden);
  })
}

function active_interface_forms() {
  return $.grep($('#interfaceForms > div'), function(f) {
    var flag = $(f).find('.destroyFlag').val();
    return (flag == false || flag == undefined);
  });
}

function confirm_flag_change(element, element_selector, massage) {
  if (!$(element).is(':checked'))
    return;

  var this_interface_id = $('#interfaceModal').data('current-id');

  var other_selected;
  other_selected = $(active_interface_forms()).find(element_selector + ':checked').closest('fieldset');
  other_selected = $.grep(other_selected, function(i) {
    return ($(i).parent().data('interface-id') != this_interface_id);
  });

  if (other_selected.length > 0) {
    return confirm(massage);
  }
}

function primary_nic_form() {
  return $(active_interface_forms()).find('.interface_primary:checked').closest('fieldset');
}

$(document).on('click', '.interface_primary', function () {
  var confirmed = confirm_flag_change(this, '.interface_primary',
    __("Some other interface is already set as primary. Are you sure you want to use this one instead?")
  );

  if (confirmed) {
    // preset dns name from host name if it's blank
    var name = $(this).closest('fieldset').find('.interface_name');
    if (name.val().length == 0)
      name.val($('#host_name').val());
  }

  return confirmed;
});

$(document).on('click', '.interface_provision', function () {
  return confirm_flag_change(this, '.interface_provision',
    __("Some other interface is already set as provisioning. Are you sure you want to use this one instead?")
  );
});

$(document).on('change', '#host_name', function () {
  // copy host name to the primary interface's name
  primary_nic_form().find('.interface_name').val($(this).val());
  update_interface_table();
  update_fqdn();
});

$(document).on('click', '.primary-flag', function () {
  var interface_id = $(this).closest('tr').data('interface-id');

  $('#interfaceForms .interface_primary:checked').prop('checked', false);
  get_interface_hidden(interface_id).find('.interface_primary').prop('checked', true);

  sync_primary_name(true);
  update_interface_table();
  update_fqdn();
});

$(document).on('click', '.provision-flag', function () {
  var interface_id = $(this).closest('tr').data('interface-id');

  $('#interfaceForms .interface_provision:checked').prop('checked', false);
  get_interface_hidden(interface_id).find('.interface_provision').prop('checked', true);

  update_interface_table();
});

function update_fqdn() {
  var host_name = $('#host_name').val();
  var domain_name = primary_nic_form().find('.interface_domain option:selected').text();

  var name = fqdn(host_name, domain_name)
  if (name.length > 0)
    name = "| " + name

  $('#hostFQDN').text(name);
}
