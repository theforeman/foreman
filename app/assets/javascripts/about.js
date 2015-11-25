$(function() {
  $(".proxy-version").each(function(index, item) {
    var item = $(item);
    var url = item.data('url');
    $.ajax({
      type: 'get',
      url:  url,
      success: function(response) {
        item.attr('title',response.message);
        if(response.success == true) {
          item.addClass('label label-success')
          item.text(__(response.message));
        } else {
          item.addClass('label label-danger')
          item.text(__('Error'));
        }
        item.tooltip({html: true});
      }
    })
  });
  $(".proxy-status, .compute-status").each(function(index, item) {
    var item = $(item);
    var url = item.data('url');
    $.ajax({
      type: 'post',
      url:  url,
      success: function(response) {
        item.text(__(response.status));
        item.attr('title',response.message);
        if(response.status == "OK"){
          item.addClass('label label-success')
        }else{
          item.addClass('label label-danger')
        }
        item.tooltip({html: true});
      }
    })
  });
});
