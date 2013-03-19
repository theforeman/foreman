// Array contains list of host ids
$.foremanSelectedHosts = readFromCookie();

// triggered by a host checkbox change
function hostChecked(box) {
  var cid = parseInt(box.id.replace("host_ids_", ""));
  if (box.checked)
    addHostId(cid);
  else
    rmHostId(cid);
  $.cookie("_ForemanSelectedHosts", JSON.stringify($.foremanSelectedHosts));
  toggle_actions();
  update_counter($("span.select_count"));
  return false;
}

function addHostId(id) {
  if (jQuery.inArray(id, $.foremanSelectedHosts) == -1)
    $.foremanSelectedHosts.push(id)
}

function rmHostId(id) {
  var pos = jQuery.inArray(id, $.foremanSelectedHosts);
  if (pos >= 0)
    $.foremanSelectedHosts.splice(pos, 1)
}

function readFromCookie() {
  try {
    if (r = $.cookie("_ForemanSelectedHosts"))
      return $.parseJSON(r);
    else
      return [];
  }
  catch(err) {
    removeForemanHostsCookie();
    return [];
  }
}

function toggle_actions() {
  var dropdown = $("#submit_multiple a");
  if ($.foremanSelectedHosts.length == 0) {
    dropdown.addClass("disabled hide");
    dropdown.attr('disabled', 'disabled');
  } else {
    dropdown.removeClass("disabled hide");
    dropdown.removeAttr('disabled');
  }
}

// setups checkbox values upon document load
$(function() {
  for (var i = 0; i < $.foremanSelectedHosts.length; i++) {
    var cid = "host_ids_" + $.foremanSelectedHosts[i];
    if ((boxes = $('#' + cid)) && (boxes[0]))
      boxes[0].checked = true;
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
  var checked = $("#check_all").is(':checked');
  $('.host_select_boxes').each(function(index, box) {
    box.checked = checked;
    hostChecked(box);
  });
  if(!checked)
    cleanHostsSelection();
  return false;
}

function toggle_multiple_ok_button(elem){
  var b = $("#confirmation-modal .btn-primary");
  if (elem.value != 'disabled')
    b.removeClass("disabled").attr("disabled", false);
  else
    b.addClass("disabled").attr("disabled", true);
}

// updates the form URL based on the action selection
$(function() {
  $('#submit_multiple a').click(function(){
    if ($.foremanSelectedHosts.length == 0) { return false }
    var title = $(this).attr('data-original-title') + ' - The following hosts are about to be changed';
    var url = $(this).attr('href') + "?" + $.param({host_ids: $.foremanSelectedHosts});
    $('#confirmation-modal .modal-header h3').text(title);
    $('#confirmation-modal .modal-body').empty().append("<img class='modal-loading' src='/assets/spinner.gif'>");
    $('#confirmation-modal').modal({show: "true", backdrop: "static"});
    $("#confirmation-modal .modal-body").load(url + " #content",
        function(response, status, xhr) {
          $("#loading").hide();
          $('#submit_multiple').val('');
          var b = $("#confirmation-modal .btn-primary");
          if ($(response).find('#content form select').size() > 0)
            b.addClass("disabled").attr("disabled", true);
          else
            b.removeClass("disabled").attr("disabled", false);
          });
    return false;
  });

  $('#confirmation-modal .btn-primary').click(function(){
    $("#confirmation-modal form").submit();
    $('#confirmation-modal').modal('hide');
  });

  $('#confirmation-modal .secondary').click(function(){
    $('#confirmation-modal').modal('hide');
  });

});

function update_counter(id) {
  if ($.foremanSelectedHosts) {
    id.text($.foremanSelectedHosts.length);
    $("#check_all").attr("checked", $.foremanSelectedHosts.length > 0 );
  }

  if ($("#check_all").attr("checked"))
    $("#check_all").attr("title", $.foremanSelectedHosts.length + " - items selected.\nUncheck to Clear Selection" );
  else
    $("#check_all").attr("title", "Select all items in this page" );
  return false;
}
