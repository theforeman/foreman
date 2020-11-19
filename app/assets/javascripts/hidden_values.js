function hidden_value_control() {
  $('.toggle-hidden-value a').click(function(event) {
    event.preventDefault();
    var link = $(event.currentTarget);
    link
      .find('i')
      .toggleClass('glyphicon-plus')
      .toggleClass('glyphicon-minus');
    link.parent().toggleClass('unhide');
  });
}

function replace_value_control(link) {
  var link = $(link);
  link
    .find('.glyphicon')
    .toggleClass('glyphicon-plus')
    .toggleClass('glyphicon-minus');
  link
    .parent()
    .find('.full-value')
    .toggleClass('unhide pull-left');
  link
    .parent()
    .parent()
    .find('a.pull-left')
    .toggleClass('hide');
}

// normal page load trigger
$(document).ready(hidden_value_control);

// ajax trigger
$(document).ajaxComplete(hidden_value_control);
