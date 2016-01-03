$(document).on('ContentLoad', function() {
  $('.nav-tabs a').on('shown.bs.tab', refreshCharts);
  showProxies();
  loadTFTP();
  setTab();
});

$(window).on('hashchange', setTab); //so buttons that link to an anchor can open that tab

function setItemStatus(item, response) {
  if(response.success) {
    item.attr('title', __('Active'));
    item.addClass('text-success');
    item.html(icon_text('ok', "", "pficon"));
  } else {
    item.attr('title', response.message);
    item.addClass('text-danger');
    item.html(icon_text('error-circle-o', "", "pficon"));
  }
  item.tooltip({html: true});
}

function setProxyVersion(item, response) {
  var text = response.message.version ? response.message.version : response.message;
  generateItem(item, response.success, text);
}

function setPluginVersion(item, response) {
  var pluginName = item.data('plugin');
  var pluginVersion;
  if (response.success)
    pluginVersion = response.message.modules ? response.message.modules[pluginName] : response.message.version;
  else
    pluginVersion = response.message;
  generateItem(item, response.success, pluginVersion);
}

function generateItem(item, status, text) {
  "use strict";
  if (status === true) {
    item.text(text);
  } else {
    item.attr('title', text);
    item.addClass('text-danger');
    item.html(icon_text('error-circle-o', "", "pficon"));
  }
  item.tooltip({html: true});
}

function showProxies(){
  $('.proxy-show').each(function(index, item) {
    var proxy = new ProxyStatus($(item));
    proxy.getVersions();
  });
}

function loadTFTP(){
  $('.proxy-tftp').each(function(index, item) {
    var item = $(item);
    var url = item.data('url');
    $.ajax({
      type: 'get',
      url: url,
      success: function (response) {
        generateItem(item, response.success, response.message);
      },
      error: function (response) {
        generateItem(item, false, response.message);
      }
    });
  });
}

function ProxyStatus(item) {
  this.url = item.data('url');
  this.item = item;
  var self = this;

  this.getVersions = function() {
    $.ajax({
      type: 'get',
      url: this.url,
      success: function (response) {
        populateData(response, self.item);
      }.bind(this),
      error: function (response) {
        populateData(response, self.item);
      }.bind(this)
    });
  };
}

function populateData(response, item) {
  item.find(".proxy-version").each(function() {
    setProxyVersion($(this), response);
  });

  $(".plugin-version").each(function() {
    setPluginVersion($(this), response);
  });

  item.find(".proxy-show-status").each(function() {
    setItemStatus($(this), response);
  });
}

// Make sure the correct tab is displayed when loading the page with an anchor,
// even if the anchor is to a sub-tab.
function setTab(){
  var anchor = document.location.hash.split('?')[0];
  if (anchor.length) {
    var parent_tab = $(anchor).parents('.tab-pane');
    if (parent_tab.exists()){
      $('.nav-tabs a[href=#'+parent_tab[0].id+']').tab('show');
    }
    $('.nav-tabs a[href='+anchor+']').tab('show');
  }
}

function filterCerts(state) {
  $('#certificates table').dataTable().fnFilter(state, 1, true);
}

function certTable() {
  activateDatatables();
  var filter = $('.puppetca-filters');
  filter.select2();
  filter.on('change', function() {filterCerts(filter.val())});
  filterCerts(__('valid')+'|'+__('pending'));
}
