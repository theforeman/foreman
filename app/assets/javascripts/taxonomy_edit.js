$(function(){
  $(":checkbox").each(function(i,item){
    ignore_checked(item);
  })
})

function ignore_checked(item){
  var current_select = $(item).closest('.tab-pane').find('select');

  if ($(item).is(':checked')) {
     current_select.prop('disabled', true);
  } else {
     current_select.removeAttr('disabled');
  }
  $(current_select).multiSelect('refresh');
  multiSelectToolTips();
}

function parent_taxonomy_changed(element) {
  var parent_id = $(element).val();

  var url = $(element).data('url');
  var data = {parent_id: parent_id}

  foreman.tools.showSpinner();
  $.ajax({
    type: 'post',
    url: url,
    data: data,
    complete: function(){ foreman.tools.hideSpinner(); },
    success: function(response) {
      $('form').replaceWith(response);
      $(document.body).trigger('ContentLoad');
      multiSelectOnLoad();
    }
  })
}
