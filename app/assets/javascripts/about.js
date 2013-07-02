$(function() {
  $(".proxy-status, .compute-status").each(function(index, item) {
    var item = $(item);
    var url = item.data('url');
    $.ajax({
      type: 'post',
      url:  url,
      success: function(response) {
        item.text(_(response.status));
        item.attr('title',response.message);
        if(response.status == "OK"){
          item.addClass('badge badge-success')
        }else{
          item.addClass('badge badge-important')
        }
        item.tooltip({html: true});
      }
    })
  })
});
