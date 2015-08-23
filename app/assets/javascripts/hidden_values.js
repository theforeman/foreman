function turn_textarea_switch(checkbox) {
  var id = checkbox.id.replace(/hidden_value$/,"value");
  var source = document.getElementById(id);
  if (checkbox.checked) {
    var target = '<input class="form-control" type="password" id="' + id + '" name="' + source.name + '" value ="' + source.value + '"></input>'
  } else {
    var target = '<textarea class="form-control" id="' + id + '" name="' + source.name + '" placeholder="Value" rows="1">' + source.value + '</textarea>'
  }
  $(source).replaceWith(target);
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
$(document).ready(hidden_value_control);

// two-pane ajax trigger
$(document).ajaxComplete(hidden_value_control);
