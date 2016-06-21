$(document).on('ContentLoad', function() {
  showSubnetUsage();
});

function showSubnetUsage(){
  $('.ipam-show-usage').each(function(index, item) {
    var subnet = new SubnetUsage($(item));
    subnet.getUsage();
  });
}

function SubnetUsage(item) {
  this.url = item.data('url');
  this.item = item;
  var self = this;

  this.getUsage = function() {
    $.ajax({
      type: 'get',
      url: this.url,
      success: function (response) {
        console.log(response.message)
        setSubnetUsage(response, self.item);
      }.bind(this),
      error: function (response) {
        setSubnetUsage(response, self.item);
      }.bind(this)
    });
  };
}

function setSubnetUsage(response, item) {
  if(response.success) {
    var used = response.message.used;
    var available = response.message.available;
    var cell = item.parent();
    cell.html(ipamUsageBar(used, available));
    var progress = cell.find('.progress');
    progress.attr('title', Jed.sprintf(__("%(used)s of %(available)s IPs in use"), {used: used, available: available}));
    progress.tooltip({html: true, container: 'body'});
  } else {
    item.attr('title', response.message);
    item.addClass('text-danger');
    item.html(icon_text('error-circle-o', "", "pficon"));
    item.tooltip({html: true, container: 'body'});
  }
}

function ipamUsageBar(used, available) {
  var percentage = Math.round(used * 100 / available);
  var bar_class = 'progress-bar-success';
  if (percentage > 95) {
    bar_class = 'progress-bar-danger';
  } else if (percentage > 90) {
    bar_class = 'progress-bar-warning';
  }

  var progress_bar = '<div class="progress progress-label-left">';
  progress_bar += '<div class="progress-bar ' + bar_class + '" role="progressbar" aria-valuenow="' + used + '" aria-valuemin="0" aria-valuemax="' + available + '" style="width: ' + percentage + '%;">';
  progress_bar += '<span>' + percentage + '%</span>';
  progress_bar += '</div>';
  progress_bar += '</div>';

  return progress_bar;
}
