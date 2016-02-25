$(function() {
  trendTypeSelected($("[id$='trend_trendable_type']"))
});


function trendTypeSelected(item){
  var is_fact = ($(item).val() == "FactName");
  var edit_mode = $(item).attr('disabled');
  $("[id$='trend_trendable_id']").prop('disabled', (is_fact && !edit_mode) ? false : true);
  $("[id$='trend_name']").prop('disabled', (is_fact && !edit_mode) ? false : true);
  if (!is_fact || !edit_mode) {
    $("[id$='trend_trendable_id']").val('');
    $("[id$='trend_name']").val('');
  }
}
