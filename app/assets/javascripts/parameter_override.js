function override_param(item) {
  var param = $(item)
    .closest('tr')
    .addClass('override-param');
  var n = param.find('[id^=name_]').text();
  var parameter_type_val = param.find('[id^=parameter_type_]').text();
  var param_value = param.find('[id^=value_]');
  var v = param_value.val();

  $('#parameters')
    .find('.btn-primary')
    .click();
  var new_param = $('#parameters')
    .find('.fields')
    .last();
  new_param.find('[id$=_name]').val(n);
  new_param.find('[id$=_parameter_type]').val(parameter_type_val);
  new_param
    .find('[id$=_value]')
    .val(v == param_value.data('hidden-value') ? '' : v);
  if (param_value.hasClass('masked-input')) {
    var alink = new_param.find('span.fa-eye-slash').closest('a'),
      hiddenValueCheckBox = new_param.find('.set_hidden_value');
    hiddenValueCheckBox.prop('checked', true);
    hiddenValueCheckBox.val('1');
    alink.click();
  }
}

function override_class_param(item) {
  var remove = $(item).data('tag') == 'remove';
  var row = $(item)
    .closest('tr')
    .toggleClass('overridden');
  var value = row.find('textarea') || row.find('select');
  row
    .find('[type=checkbox]')
    .prop('checked', false)
    .toggle();
  row.find('input, textarea').prop('disabled', remove);
  row.find('input, select').prop('disabled', remove);
  row.find('.send_to_remove').prop('disabled', false);
  row.find('.destroy').val(remove);
  value.val(value.attr('data-inherited-value'));
  $(item)
    .hide()
    .siblings('.btn-override')
    .show();
}
