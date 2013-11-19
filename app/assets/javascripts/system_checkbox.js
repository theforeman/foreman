// Array contains list of system ids
$.cookieName = "_ForemanSelected" + window.location.pathname.replace(/\//,"");
$.foremanSelectedSystems = readFromCookie();

// triggered by a system checkbox change
function systemChecked(box) {
  var cid = parseInt(box.id.replace("system_ids_", ""));
  if (box.checked)
    addSystemId(cid);
  else
    rmSystemId(cid);
  $.cookie($.cookieName, JSON.stringify($.foremanSelectedSystems));
  toggle_actions();
  update_counter();
  return false;
}

function addSystemId(id) {
  if (jQuery.inArray(id, $.foremanSelectedSystems) == -1)
    $.foremanSelectedSystems.push(id)
}

function rmSystemId(id) {
  var pos = jQuery.inArray(id, $.foremanSelectedSystems);
  if (pos >= 0)
    $.foremanSelectedSystems.splice(pos, 1)
}

function readFromCookie() {
  try {
    if (r = $.cookie($.cookieName))
      return $.parseJSON(r);
    else
      return [];
  }
  catch(err) {
    removeForemanSystemsCookie();
    return [];
  }
}

function toggle_actions() {
  var dropdown = $("#submit_multiple a");
  if ($.foremanSelectedSystems.length == 0) {
    dropdown.addClass("disabled hide");
    dropdown.attr('disabled', 'disabled');
  } else {
    dropdown.removeClass("disabled hide");
    dropdown.removeAttr('disabled');
  }
}

// setups checkbox values upon document load
$(function() {
  for (var i = 0; i < $.foremanSelectedSystems.length; i++) {
    var cid = "system_ids_" + $.foremanSelectedSystems[i];
    if ((boxes = $('#' + cid)) && (boxes[0]))
      boxes[0].checked = true;
  }
  toggle_actions();
  update_counter();
  return false;
});

function removeForemanSystemsCookie() {
  $.cookie($.cookieName, null);
}

function resetSelection() {
  removeForemanSystemsCookie();
  $.foremanSelectedSystems = [];
}

function cleanSystemsSelection() {
  $('.system_select_boxes').each(function(index, box) {
    box.checked = false;
    systemChecked(box);
  });
  resetSelection();
  toggle_actions();
  update_counter();
  return false;
}

function toggleCheck() {
  var checked = $("#check_all").is(':checked');
  $('.system_select_boxes').each(function(index, box) {
    box.checked = checked;
    systemChecked(box);
  });
  if(!checked)
    cleanSystemsSelection();
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
    if ($.foremanSelectedSystems.length == 0 || $(this).hasClass('dropdown-toggle')) { return false }
    var title = $(this).attr('data-original-title');
    var url = $(this).attr('href') + "?" + $.param({system_ids: $.foremanSelectedSystems});
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

function update_counter() {
  var item = $("#check_all");
  if ($.foremanSelectedSystems) {
    $(".select_count").text($.foremanSelectedSystems.length);
    item.attr("checked", $.foremanSelectedSystems.length > 0 );
  }
  var title = "";
  if (item.attr("checked"))
    title = $.foremanSelectedSystems.length + " - " + item.attr("uncheck-title");
  else
    title = item.attr("check-title");

  item.attr("data-original-title", title );
  item.tooltip();
  return false;
}
