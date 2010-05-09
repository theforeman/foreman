function toggleCheck() {
  $$('#host_select_form input.host_select_boxes').each(function(box){
                                                                box.checked=!box.checked;
                                                                insertHostVal(box);
                                                                });
  return false;
}
function insertHostVal(cbox) {
  var request = new Ajax.Request('hosts/save_checkbox', {
                parameters: { box: cbox.value, is_checked: cbox.checked },
                onSuccess: function(res){
                   return false;
                },
                onFailure: function(res){
                   alert("Something failed! Select the checkbox again.")
                   return false;
                }
              });
}
