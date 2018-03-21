// Array contains list of host ids
$.cookieName = "_ForemanSelected" + window.location.pathname.replace(/\//,"");
$.foremanSelectedHosts = readFromCookie();

// triggered by a host checkbox change
function hostChecked(box) {
  var multiple_alert = $("#multiple-alert");
  var cid = parseInt(box.id.replace("host_ids_", ""));
  if (box.checked)
    addHostId(cid);
  else{
    rmHostId(cid);
    if (multiple_alert.length){
      multiple_alert.hide('slow');
      multiple_alert.data('multiple', false)
    }
  }
  $.cookie($.cookieName, JSON.stringify($.foremanSelectedHosts), { secure: location.protocol === 'https:' });
  toggle_actions();
  update_counter();
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
    if (r = $.cookie($.cookieName))
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
  var dropDownContainer = $("#submit_multiple");
  var dropdown = dropDownContainer.find("a");
  var disabledMessage = __("Please select hosts to perform action on.");
  if ($.foremanSelectedHosts.length == 0) {
    dropdown.addClass("disabled");
    dropdown.attr('disabled', 'disabled');
    dropDownContainer.attr('title', disabledMessage);
  } else {
    dropdown.removeClass("disabled");
    dropdown.removeAttr('disabled');
    dropDownContainer.removeAttr('title');
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
  update_counter();
  $("#search-form").submit(function(){
    resetSelection();
  });
  return false;
});

function removeForemanHostsCookie() {
  $.removeCookie($.cookieName);
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
  update_counter();
  return false;
}

function multiple_selection() {
  var total = $("#pagination").data("count");
  var alert_text = tfm.i18n.sprintf(n__("Single host is selected in total",
    "All <b> %d </b> hosts are selected.", total), total);
  var undo_text = __("Undo selection");
  var multiple_alert = $("#multiple-alert");
  multiple_alert.find(".text").html(alert_text + ' <a href="#" onclick="undo_multiple_selection();">' + undo_text + '</a>');
  multiple_alert.data('multiple', true);
  $(".select_count").html(total);
}

function undo_multiple_selection() {
  var pagination = pagination_metadata();
  var alert_text = tfm.i18n.sprintf(n__("Single host on this page is selected.",
    "All %s hosts on this page are selected.", pagination.per_page), pagination.per_page);
  var select_text = tfm.i18n.sprintf(n__("Select this host",
    "Select all<b> %s </b> hosts", pagination.total), pagination.total);
  var multiple_alert = $("#multiple-alert");
  multiple_alert.find(".text").html( alert_text + ' <a href="#" onclick="multiple_selection();">' + select_text + '</a>');
  multiple_alert.data('multiple', false);
  $(".select_count").html(pagination.per_page);
}

function toggleCheck() {
  var pagination = pagination_metadata();
  var multiple_alert = $("#multiple-alert");
  var checked = $("#check_all").is(':checked');
  $('.host_select_boxes').each(function(index, box) {
    box.checked = checked;
    hostChecked(box);
  });
  if(checked && (pagination.per_page - pagination.total < 0) ) {
    multiple_alert.show('slow');
    multiple_alert.data('multiple', false);
  }
  else if (!checked) {
    multiple_alert.hide('slow');
    multiple_alert.data('multiple', false);
    cleanHostsSelection();
  }
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
  $('#confirmation-modal .secondary').click(function(){
    $('#confirmation-modal').modal('hide');
  });
});

function submit_modal_form() {
  if (!$('#keep_selected').is(':checked'))
    removeForemanHostsCookie();
  if (is_multiple()){
    var query = $("<input>")
      .attr("type", "hidden")
      .attr("name", "search").val($("#search").val());
    $("#confirmation-modal form").append(query);
  }
  $("#confirmation-modal form").submit();
  $('#confirmation-modal').modal('hide');
}

function is_multiple() {
  return $("#multiple-alert").data('multiple');
}

function get_bulk_param() {
  return is_multiple() ? {search: $("#search").val()} : {host_ids: $.foremanSelectedHosts}
}

function build_modal(element, url) {
  var data = get_bulk_param();
  var title = $(element).attr('data-dialog-title');
  $('#confirmation-modal .modal-header h4').text(title);
  $('#confirmation-modal .modal-body').empty()
    .append("<div class='modal-spinner spinner spinner-lg'></div>");
  $('#confirmation-modal').modal();
  $("#confirmation-modal .modal-body").load(url + " #content", data,
    function(response, status, xhr) {
      $("#loading").hide();
      $('#submit_multiple').val('');
      if (is_multiple())
        $("#multiple-modal-alert").show();
      var b = $("#confirmation-modal .btn-primary");
      if ($(response).find('#content form select').length > 0)
        b.addClass("disabled").attr("disabled", true);
      else
        b.removeClass("disabled").attr("disabled", false);
    });
  return false;
}

function build_redirect(url) {
  var data = get_bulk_param();
  var url = url + "?" + $.param(data);
  window.location.replace(url);
}

function pagination_metadata() {
  var pagination = $("#pagination");
  var total = pagination.data("count");
  var per_page = $("#per_page").val();
  return { total: total, per_page: per_page }
}

function update_counter() {
  var item = $("#check_all");
  if ($.foremanSelectedHosts)
    $(".select_count").text($.foremanSelectedHosts.length);
  var title = "";
  if (item.prop('checked'))
    title = pagination_metadata().per_page + " - " + item.attr("uncheck-title");
  else
    title = item.attr("check-title");

  item.attr("data-original-title", title );
  item.tooltip({
    trigger : 'hover'
  })
  return false;
}
