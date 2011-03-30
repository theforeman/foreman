function toggleCheck() {
  $('#host_select_form input.host_select_boxes').each(function(box){
    box.checked=!box.checked;
    insertHostVal(box);
  });
  return false;
}
function insertHostVal(cbox) {
  $.ajax({
    type: "POST",
    url: 'hosts/save_checkbox',
    data: {box: cbox.value, is_checked: cbox.checked},
    success: function(res){ return false; },
    failure: function(res){
      alert("Something failed! Select the checkbox again.");
      return false;
    }
  });
}
