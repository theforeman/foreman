$(function() {
  trendTypeSelected($("[id$='trend_trendable_type']"))
});


function trendTypeSelected(item){
  var is_fact = ($(item).val() == "FactName");
  var edit_mode = $(item).attr('disabled');
  $("[id$='trend_trendable_id']").attr('disabled', (is_fact && !edit_mode) ? null : 'disabled');
}