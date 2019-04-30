$(document).on('ContentLoad', function() {
  var dialog = $('#review_before_build');
  $('#build-review').click(function() {
    dialog.find('.modal-body #build_status').html('');
    $('.loading').addClass('visible');
    $.ajax({
      type: 'get',
      url: $(this).attr('data-url'),

      success: function(result) {
        $('#review_before_build')
          .find('.modal-body #build_status')
          .html(result);
      },
      complete: function() {
        $('.loading').removeClass('visible');
      },
    });
  });
  dialog.on('change', '#host_build', function() {
    $('#build_form')
      .find('input.submit')
      .val(this.checked ? __('Reboot and build') : __('Build'));
  });

  dialog.on('click', '#recheck_review', function() {
    $('#build-review').click();
  });

  var action_buttons = $('.btn-toolbar a')
    .not('.dropdown-toggle')
    .not('.dropdown-toggle > a');
  var wait_msg = $('#processing_message');

  wait_msg.modal({
    backdrop: 'static',
    keyboard: false,
    show: false,
  });

  var is_in_array = function(val, arr) {
    return arr.indexOf(val) > -1;
  };

  action_buttons.on('click', function() {
    if (this.id === 'delete-button' && !confirm($(this).attr('data-message')))
      return false;
    if (
      is_in_array(this.id, [
        'delete-button',
        'edit-button',
        'cancel-build-button',
      ])
    ) {
      action_buttons.prop('disabled', 1);
      wait_msg.modal('show');
    }
  });
});
