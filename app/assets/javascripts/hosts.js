$(function () {
  var dialog = $("#review_before_build");
  $("#build-review").click(function () {
    dialog.find(".modal-body #build_status").html('');
    $('.loading').addClass('visible');
    $.ajax({
      type: 'get',
      url: $(this).attr('data-url'),

      success: function (result) {
        $("#review_before_build").find(".modal-body #build_status").html(result);
      },
      complete: function () {
        $('.loading').removeClass('visible');
      }
    });
  });
  dialog.on('change', "#host_build", function () {
    $('#build_form').find('input.submit').val((this.checked) ? (__("Reboot and build")) : (__("Build")));
  });

  dialog.on('click', "#recheck_review", function () {
    $("#build-review").click();
  });
});
