$(function() {
  'use strict';
  $('.compute-status').each(function(index, item) {
    var item = $(item);
    var url = item.data('url');
    $.ajax({
      type: 'post',
      url: url,
      success: function(response) {
        item.text(__(response.status));
        item.attr('title', response.message);
        if (response.status === 'OK') {
          item.addClass('label label-success');
        } else {
          item.addClass('label label-danger');
        }
        item.tooltip({ html: true });
      },
    });
  });
});
