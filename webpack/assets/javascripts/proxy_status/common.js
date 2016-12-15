export function showProxies(){
  $('.proxy-show').each(function(index, item) {
    var proxy = new ProxyStatus($(item));
    proxy.getVersions();
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

// Make sure the correct tab is displayed when loading the page with an anchor,
// even if the anchor is to a sub-tab.
export function setTab(){
  var anchor = document.location.hash.split('?')[0];
  if (anchor.length) {
    var parent_tab = $(anchor).parents('.tab-pane');
    if (parent_tab.exists()){
      $('.nav-tabs a[href=#'+parent_tab[0].id+']').tab('show');
    }
    $('.nav-tabs a[href='+anchor+']').tab('show');
  }
}

