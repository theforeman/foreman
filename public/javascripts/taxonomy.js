$(function(){
  $(":checkbox").each(function(i,item){
    ignore_checked(item);
  })
})

function ignore_checked(item){
  var active_tab = $(item).closest('.tab-pane');
  var list_items = active_tab.find('.ms-container li');

  if ($(item).is(':checked')) {
       list_items.addClass('disabled');
    } else {
       list_items.removeClass('disabled');
       active_tab.find('.ms-container li.disabled_item').addClass('disabled');
    }

}
