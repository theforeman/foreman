function schedulerHintFilterSelected(item){
  var filter = $(item).val();
  if (filter == '') {
    $('#scheduler_hint_wrapper').empty();
  } else {
    var url = $(item).attr('data-url');
    var data = serializeForm().replace('method=patch', 'method=post');
    tfm.tools.showSpinner();
    $.ajax({
      type:'post',
      url: url,
      data: data,
      complete: function(){
        tfm.tools.hideSpinner();
      },
      error: function(jqXHR, status, error){
        $('#scheduler_hint_wrapper').html(Jed.sprintf(__("Error loading scheduler hint filters information: %s"), error));
        $('#compute_resource_tab a').addClass('tab-error');
      },
      success: function(result){
        $('#scheduler_hint_wrapper').html(result);
      }
    })
  }
}
