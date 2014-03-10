$(function(){
  $(":checkbox").each(function(i,item){
    ignore_checked(item);
  })
})

function ignore_checked(item){
  var current_select = $(item).closest('.tab-pane').find('select');

  if ($(item).is(':checked')) {
     current_select.attr('disabled', 'disabled');
  } else {
     current_select.removeAttr('disabled');
  }
  $(current_select).multiSelect('refresh');
  multiSelectToolTips();
}
