$(function() {
  trendTypeSelected($("[id$='trend_trendable_type']"))
});


function trendTypeSelected(item){
  var is_fact = ($(item).val() == "FactName");
  var edit_mode = $(item).attr('disabled');
  $("[id$='trend_trendable_id']").attr('disabled', (is_fact && !edit_mode) ? null : 'disabled');
  $("[id$='trend_name']").attr('disabled', (is_fact && !edit_mode) ? null : 'disabled');
  if (!is_fact || !edit_mode) {
    $("[id$='trend_trendable_id']").val('');
    $("[id$='trend_name']").val('');
  }
}