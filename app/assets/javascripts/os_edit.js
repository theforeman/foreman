$(document).on('ContentLoad', function() {
  $('#operatingsystem_architecture_ids').parent().append($('#add_architecture_btn'));
  $('#add_architecture_btn').show();
});

$(document).on('click','#add_architecture .submit', function() {
  var arch_form = $('#add_architecture form');
  $.ajax({
    type:'POST',
    url: arch_form.attr('action'),
    data: arch_form.serialize(),
    context: this,
    success: function(response) {
      // append newly created architecture to the multiselect
      appendMultiselectOption(
        $('#operatingsystem_architecture_ids'),
        'operatingsystem[architecture_ids]',
        response.architecture.id,
        response.architecture.name
      );

      // and hide the modal window
      $('#add_architecture').modal('hide');
      $.jnotify(_("Architecture created") , {type: 'success'});
    },
    error: function(response) {
      // parse errors and display them in a notification
      response = $.parseJSON(response.responseText);
      $.jnotify(response.errors.join("<br>"), {type: 'error'});
    }
  });
});

$(document).on('click','#add_architecture_btn', function() {
  $('#add_architecture').modal();
  return false;
});
