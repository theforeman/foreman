// Array contains list of host ids
$.foremanSelectedHosts = readFromCookie();

// triggered by a host checkbox change
function hostChecked(box) {
  var cid = parseInt(box.id.replace("host_ids_", ""));
  if (box.checked) {
    addHostId(cid);
  } else {
    rmHostId(cid);
  }
  $.cookie("_ForemanSelectedHosts", JSON.stringify($.foremanSelectedHosts));
  toggle_actions();
  update_counter($("span.select_count"));
  return false;
}

function addHostId(id) {
  if (jQuery.inArray(id, $.foremanSelectedHosts) == -1) {
    $.foremanSelectedHosts.push(id)
  }
}

function rmHostId(id) {
  var pos = jQuery.inArray(id, $.foremanSelectedHosts);
  if (pos >= 0) {
    $.foremanSelectedHosts.splice(pos, 1)
  }
}

function readFromCookie() {
  try {
    if (r = $.cookie("_ForemanSelectedHosts")) {
      return JSON.parse(r);
    } else {
      return []
    }
  }
  catch(err) {
    removeForemanHostsCookie();
    return []
  }
}

function toggle_actions() {
  if ($.foremanSelectedHosts.length > 0) {
    $("#Submit_multiple").enable()
  } else {
    $("#Submit_multiple").disable()
  }
}

// setups checkbox values upon document load
$(function() {
  for (var i = 0; i < $.foremanSelectedHosts.length; i++) {
    var cid = "host_ids_" + $.foremanSelectedHosts[i];
    if ((boxes = $('#' + cid)) && (boxes[0])) {
      boxes[0].checked = true;
    }
  }
  toggle_actions();
  update_counter($("span.select_count"));
  return false;
});

function removeForemanHostsCookie() {
  $.cookie("_ForemanSelectedHosts", null);
}

function resetSelection() {
  removeForemanHostsCookie();
  $.foremanSelectedHosts = [];
}

function cleanHostsSelection() {
  $('.host_select_boxes').each(function(index, box) {
    box.checked = false;
    hostChecked(box);
  });
  resetSelection();
  toggle_actions();
  update_counter($("span.select_count"));
  return false;
}

function toggleCheck() {
  $('.host_select_boxes').each(function(index, box) {
    box.checked = !box.checked;
    hostChecked(box);
  });
  return false;
}

// updates the form URL based on the action selection
function submit_multiple(path) {
  var url = path + "?" + $.param({host_ids: $.foremanSelectedHosts});
  var html = $('<div></div>').appendTo('body').load(url + " #content");
  var title = $('select [value=\"' + path + '\"]').text();
  html.dialog({
    title: title,
    width: 700,
    modal: true,
    close: function(event, ui) {}
  });
  cleanHostsSelection();
  return false;
}

function update_counter(id) {
  if ($.foremanSelectedHosts)
    id.text($.foremanSelectedHosts.length);
  return false;
}
