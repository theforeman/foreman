function setItemStatus(item, response) {
  if(response.success) {
    item.attr('title', __('Active'));
    item.addClass('text-success');
    item.html(icon('ok-sign'));
  } else {
    item.attr('title', response.message);
    item.addClass('text-danger');
    item.html(icon('exclamation-sign'));
  }
  item.tooltip({html: true});
}

function setProxyVersion(item, response) {
  var text = response.message.version ? response.message.version : response.message;
  generateItem(item, response.success, text);
}

function setPluginVersion(item, response) {
  var pluginName = item.data('plugin');
  var pluginVersion = response.message.modules ? response.message.modules[pluginName] : response.message;
  generateItem(item, response.success, pluginVersion);
}

function generateItem(item, status, text) {
  "use strict";
  if (status === true) {
    item.text(text);
  } else {
    item.attr('title', text);
    item.addClass('text-danger');
    item.html(icon('exclamation-sign'));
  }
  item.tooltip({html: true});
}

$(function() {
  $('.proxy-show').each(function(index, item) {
    var proxy = new ProxyStatus($(item));
    proxy.getVersions();
  });

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
});

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
  $(item.children().find(".proxy-version")).each(function(index, i) {
    var item = $(i);
    setProxyVersion(item, response);
  });

  $(".plugin-version").each(function(index, i) {
    var item = $(i);
    setPluginVersion(item, response);
  });

  $(item.children().find(".proxy-show-status")).each(function(index, i) {
    var item = $(i);
    setItemStatus(item, response);
  });
}
