$(function() {
  $(':checkbox').each(function(i, item) {
    ignore_checked(item);
  });

  $('form').on('submit', function() {
    $('select.without_select2').prop('disabled', false);
    $('.ms-selection li.ms-elem-selection').removeClass('disabled');
  });
});

function ignore_checked(item) {
  var current_select = $(item)
    .closest('.tab-pane')
    .find('select');

  if ($(item).is(':checked')) {
    current_select.attr('disabled', 'disabled');
    current_select.find("option").prop('selected', true);
  } else {
    current_select.removeAttr('disabled');
  }
  if (!$(current_select).hasClass('parameter_type_selection')) {
    $(current_select).multiSelect('refresh');
  }
  multiSelectToolTips();
}

function parent_taxonomy_changed(element) {
  var parent_id = $(element).val();

  var url = $(element).data('url');
  var data = { parent_id: parent_id };

  tfm.tools.showSpinner();
  $.ajax({
    type: 'post',
    url: url,
    data: data,
    complete: function() {
      tfm.tools.hideSpinner();
    },
    success: function(response) {
      $('form').replaceWith(response);
      $(document.body).trigger('ContentLoad');
      multiSelectOnLoad();
    },
  });
}
