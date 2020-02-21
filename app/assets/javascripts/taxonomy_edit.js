$(function() {
  $("input.ignore_types:not(.dual_list)").each(function(i, item) {
    ignore_checked(item, false);
  });
});

function ignore_checked(item, dual_list) {
  if(dual_list){
    var checkBox = $(item);
    var dualList = checkBox.closest('.tab-pane').find('.dual-list');

    if (checkBox.is(':checked')) {
      dualList.addClass('disabled');
    } else {
      dualList.removeClass('disabled');
    }
  }else{
    var current_select = $(item)
      .closest('.tab-pane')
      .find('select');

    if ($(item).is(':checked')) {
      current_select.attr('disabled', 'disabled');
    } else {
      current_select.removeAttr('disabled');
    }
    if (!$(current_select).hasClass('parameter_type_selection')) {
      $(current_select).multiSelect('refresh');
    }
    multiSelectToolTips();
  }
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
