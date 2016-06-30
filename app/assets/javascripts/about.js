$(function() {
  "use strict";

  $(".compute-status").each(function(index, item) {
    var item = $(item);
    var url = item.data('url');
    $.ajax({
      type: 'post',
      url:  url,
      success: function(response) {
        item.text(__(response.status));
        item.attr('title',response.message);
        if(response.status === "OK"){
          item.addClass('label label-success')
        }else{
          item.addClass('label label-danger')
        }
        item.tooltip({html: true});
      }
    });
  });

  $(document).ready(loadUpdates);

  function loadUpdates() {
    if ($('#plugins-table').length > 0) {
      $.ajax({
        type: 'get',
        url: $('#plugins-table').data('url'),
        success: listVersions
      });
    }

    if ($('#latest-updates').length > 0) {
      $.ajax({
        type: 'get',
        url: $('#latest-updates').data('url'),
        success: showLatest,
      });
    }
  }

  function showLatest(response) {
    $('#latest-updates').next().remove();
    response.current_latest = response.current_latest || "N/A"
    response.lastest = response.latest || "N/A"
    var versions = response.current_latest + ", " + response.latest
    $('#latest-updates').append("<span>" + versions + "</span>")
  }

  function listVersions(response) {
    var rows = $('#plugins-table > tbody > tr')
    response.forEach(function (item) {
      var row = null,
          name = Object.keys(item).pop();
      row = $(rows).filter(function (index, ele) {
        if($(ele).children().first().text() === name) {
          return ele;
        }
      });
      showPluginUpdate(row, item[name]);
    });
  }

  function showPluginUpdate(row, version) {
    $(row).children().last().find("div").remove();
    version = version || "N/A";
    $(row).children().last().append("<div>" + version + "</div>");
  }
});
