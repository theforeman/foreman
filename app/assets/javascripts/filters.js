$(document).ready(function () {
  $('#filter_resource_type').change(function () {
    $.ajax({
      url: $(this).data('url'),
      data: {
        resource_type: $('#filter_resource_type').val()
      },
      dataType: "script"
    });
  });

  $('#filter_unlimited').change(function () {
    $('#search').prop('disabled', $(this).prop('checked'));
  });

  $('li a[href="#organizations"]').toggle($('#filter_resource_type').data('allow-organizations'));
  $('li a[href="#locations"]').toggle($('#filter_resource_type').data('allow-locations'));
});
