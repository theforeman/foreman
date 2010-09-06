/* redMine - project management software
   Copyright (C) 2006-2008  Jean-Philippe Lang */

function checkAll (id, checked) {
  var els = Element.descendants(id);
  for (var i = 0; i < els.length; i++) {
    if (els[i].disabled==false) {
      els[i].checked = checked;
    }
  }
}

function toggleCheckboxesBySelector(selector) {
  boxes = $$(selector);
  var all_checked = true;
  for (i = 0; i < boxes.length; i++) { if (boxes[i].checked == false) { all_checked = false; } }
  for (i = 0; i < boxes.length; i++) { boxes[i].checked = !all_checked; }
}

function toggleRowGroup(el) {
  var tr = Element.up(el, 'tr');
  var n = Element.next(tr);
  tr.toggleClassName('open');
  while (n != undefined && !n.hasClassName('group')) {
    Element.toggle(n);
    n = Element.next(n);
  }
}
