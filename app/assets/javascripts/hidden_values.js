function turn_textarea_switch(checkbox) {
  var target, session;
  var id = checkbox.id.replace(/hidden_value$/, "value");
  var source = document.getElementById(id);
  var $editorContainer = $('.editor-container');

  if (checkbox.checked) {
    target = $('<input/>').attr({ type: 'password', id: id, name: source.name, value: $(source).val(), class: 'form-control'});
    $editorContainer.find('.navbar').hide();
    $editorContainer.find('.ace_editor').remove();
    $(source).replaceWith(target);
  } else if ($('.editor-container').length > 0) {
    target = $('<textarea/>').attr({class: 'form-control editor_source hide', id: id, name: source.name, placeholder: 'Value', rows: 1, value: $(source).val()});
    $editorContainer.find('.navbar').show();
    $(source).replaceWith(target);

    onEditorLoad();
    session = Editor.getSession();
    session.setValue($(source).val());
  } else {
    var target = $('<textarea/>').attr({class: 'form-control', id: id, name: source.name, placeholder: 'Value', rows: 1, value: $(source).val()});
    $(source).replaceWith(target);
  }
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
