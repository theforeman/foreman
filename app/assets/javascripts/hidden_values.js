function turn_text_switch() {
  $('.hidden_value_text_switch').each(function (index, switch_field) {
    if ($(switch_field).attr('data-switch-active') != 'true') {
      $(switch_field).change(function () {
        value = $("#common_parameter_value")[0];
        value.type = (this.checked ? 'password' : 'text');
      });
      $(this).attr('data-switch-active', 'true');
    }
  })
}

function turn_textarea_switch() {
  $('.hidden_value_textarea_switch').each(function (index, switch_field) {
    if ($(switch_field).attr('data-switch-active') != 'true') {
      $(switch_field).change(function () {
        var source = $(this).closest('tr').children('td.value').children()[0];
        if (this.checked) {
          var target = '<input class="form-control" type="password" id="' + source.id + '" name="' + source.name + '" value ="' + source.value + '"></input>'
        } else {
          var target = '<textarea class="form-control" cols="40" id="' + source.id + '" name="' + source.name + '" placeholder="Value" rows="1">' + source.value + '</textarea>'
        }
        $(source).replaceWith(target);
      });
      this.value = '1';
      $(this).attr('data-switch-active', 'true');
    }
  })
}

// normal page load trigger
$(document).ready(turn_text_switch);

// two-pane ajax trigger
$(document).ajaxComplete(turn_text_switch);

// normal page load trigger
$(document).ready(turn_textarea_switch);

// two-pane ajax trigger
$(document).ajaxComplete(turn_textarea_switch);
