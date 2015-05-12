function turn_textarea_switch() {
  $('.hidden_value_textarea_switch').each(function (index, switch_field) {
    if ($(switch_field).attr('data-switch-active') != 'true') {
      $(switch_field).change(function () {
        var source = $(this).closest('tr').children('td.value').children()[0];
        if (source === undefined) {
          source = $(this).closest('div.form-group').parent().prev().children().children('div.col-md-4').children()[0];
        }
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

function hidden_value_control(){
  $(".toggle-hidden-value a").click(function(event){
    event.preventDefault();
    var link = $(event.currentTarget);
    link.find("i").toggleClass("glyphicon-plus").toggleClass("glyphicon-minus");
    link.parent().toggleClass("unhide");
  });
}

function replace_value_control(link) {
  var link = $(link);
  link.find("i").toggleClass("glyphicon-plus").toggleClass("glyphicon-minus");
  link.parent().find(".full-value").toggleClass("unhide pull-left");
  link.parent().parent().find('a.pull-left').toggleClass("hide");
}

// normal page load trigger
$(document).ready(turn_textarea_switch);

// two-pane ajax trigger
$(document).ajaxComplete(turn_textarea_switch);

// normal page load trigger
$(document).ready(hidden_value_control);

// two-pane ajax trigger
$(document).ajaxComplete(hidden_value_control);
