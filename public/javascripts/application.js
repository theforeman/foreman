function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g")
  $(link).parent().before(content.replace(regexp, new_id));
}

function checkAll (id, checked) {
  $(id).find(":checkbox:not([disabled='disabled'])").attr('checked',checked)
}

function toggleCheckboxesBySelector(selector) {
  boxes = $(selector);
  var all_checked = true;
  for (i = 0; i < boxes.length; i++) { if (boxes[i].checked == false) { all_checked = false; } }
  for (i = 0; i < boxes.length; i++) { boxes[i].checked = !all_checked; }
}

function toggleRowGroup(el) {
  var tr = $(el).closest('tr');
  var n = tr.next();
  tr.toggleClass('open');
  while (n != undefined && !n.hasClass('group')) {
    n.toggle();
    n = n.next();
  }
}
