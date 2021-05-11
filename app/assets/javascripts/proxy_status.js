//= require proxy_status/puppet
//= require proxy_status/logs

$(document).on('ContentLoad', function() {
  $('a[data-toggle="tab"]').on('click', function(e) {
    history.pushState(
      null,
      null,
      document.location.pathname + $(this).attr('href')
    );
  });
  showProxies();
  loadTFTP();
  tfm.tools.setTab();
});

$(window).on('hashchange', tfm.tools.setTab); //so buttons that link to an anchor can open that tab

function setItemStatus(item, response) {
  if (response.success && response.message && response.message.warning) {
    item.attr('title', response.message.warning.message);
    item.addClass('text-warning');
    item.html(tfm.tools.iconText('warning-triangle-o', '', 'pficon'));
  } else if (response.success) {
    item.attr('title', __('Active'));
    item.addClass('text-success');
    item.html(tfm.tools.iconText('ok', '', 'pficon'));
  } else {
    item.attr('title', response.message);
    item.addClass('text-danger');
    item.html(tfm.tools.iconText('error-circle-o', '', 'pficon'));
  }
  item.tooltip({ html: true });
}

function setProxyVersion(item, response) {
  var text = response.message.version
    ? response.message.version
    : response.message;
  generateItem(item, response.success, text);
}

function setPluginVersion(item, response) {
  var pluginName = item.data('plugin');
  var pluginVersion;
  if (response.success)
    pluginVersion = response.message.modules
      ? response.message.modules[pluginName]
      : response.message.version;
  else pluginVersion = response.message;
  generateItem(item, response.success, pluginVersion);
}

function generateItem(item, status, text) {
  'use strict';
  if (status === true) {
    item.text(text);
  } else {
    item.attr('title', text);
    item.addClass('text-danger');
    item.html(tfm.tools.iconText('error-circle-o', '', 'pficon'));
  }
  item.tooltip({ html: true });
}

function showProxies() {
  $('.proxy-show').each(function(index, item) {
    var proxy = new ProxyStatus($(item));
    proxy.getVersions();
  });
}

function loadTFTP() {
  $('.proxy-tftp').each(function(index, item) {
    var item = $(item);
    var url = item.data('url');
    $.ajax({
      type: 'get',
      url: url,
      success: function(response) {
        generateItem(item, response.success, response.message);
      },
      error: function(response) {
        generateItem(item, false, response.message);
      },
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
      success: function(response) {
        populateData(response, self.item);
      }.bind(this),
      error: function(response) {
        populateData(response, self.item);
      }.bind(this),
    });
  };
}

function populateData(response, item) {
  item.find('.proxy-version').each(function() {
    setProxyVersion($(this), response);
  });

  $('.plugin-version').each(function() {
    setPluginVersion($(this), response);
  });

  item.find('.proxy-show-status').each(function() {
    setItemStatus($(this), response);
  });
}
