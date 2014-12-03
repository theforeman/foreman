

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
}

function close_interface_modal() {
  var modal_window = $('#interfaceModal');
  var interface_id = modal_window.data('current-id');

  var interface_row = get_interface_row(interface_id);
  update_interface_row(interface_row, modal_window);

  modal_window.modal('hide');
  modal_window.removeData('current-id');

  var interface_hidden = get_interface_hidden(interface_id);
  interface_hidden.html('');
  interface_hidden.append(modal_window.find('.modal-body').contents());
}

function get_interface_template_clone() {
  var content = $('.interfaces_fields_template').html();
  var interface_id = new Date().getTime();

  content = fix_template_names(content, 'interfaces', interface_id);

  var hidden = $(content);

  $('#interfaceForms').closest("form").trigger({type: 'nested:fieldAdded', field: hidden});
  $('a[rel="popover"]').popover({html: true});
  $('a[rel="twipsy"]').tooltip();

  hidden.attr('id', 'interfaceHidden'+interface_id);
  hidden.data('interface-id', interface_id);

  return hidden;
}

function get_interface_row(interface_id) {
  var interface_row = $('#interface'+interface_id);
  if ( interface_row.length == 0) {
    interface_row = $('#interfaceTemplate').clone(true);
    interface_row.attr('id', 'interface'+interface_id);

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
    interface_hidden.attr('style', 'display: none');
    interface_hidden.attr('id', 'interfaceHidden'+interface_id);
    interface_hidden.data('interface-id', interface_id);

    $('#interfaceForms').append(interface_hidden);
  }
  return interface_hidden;
}

function update_interface_row(row, modal_window) {
  row.find('.type').html(modal_window.find('.interface_type option:selected').text());
  row.find('.identifier').html(modal_window.find('.interface_identifier').val());
  row.find('.mac').html(modal_window.find('.interface_mac').val());
}
