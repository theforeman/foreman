function override_param(item) {
  var param = $(item)
    .closest('tr')
    .addClass('override-param');
  var n = param.find('[id^=name_]').text();
  var parameter_type_val = param.find('[id^=parameter_type_]').text();
  var param_value = param.find('[id^=value_]');
  var v = param_value.val();

  var addParameterButton = $('#parameters').find('.btn-primary');
  addParameterButton.click();
  var directionOfAddedItems = addParameterButton.attr('direction');
  var new_param = $('#parameters').find('.fields');
  if(directionOfAddedItems === 'append'){
    new_param = new_param.last();
  } else {
    new_param = new_param.first();
  }
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
