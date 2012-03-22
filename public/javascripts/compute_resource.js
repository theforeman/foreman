// AJAX load vm listing
$(function() {
  var url = $("#vms").attr('data-url');
  $('#vms').load(url + ' table', function(response, status, xhr) {
    if (status == "error") {
      $('#vms_spinner').html("Sorry but there was an error: " + xhr.status + " " + xhr.statusText);
    }
  });
});

function providerSelected(item)
{
  var provider = $(item).val();
  if(provider == "") {
    $("[type=submit]").attr("disabled",true);
    return false;
  }
  $("[type=submit]").attr("disabled",false);
  var url = $(item).attr('data-url');
  $.ajax({
        type:'post',
        url: url,
        data:'provider=' + provider,
        success: function(result){
          $('#compute_connection').html($(result).children("#compute_connection"));
          $('#compute_connection').append($(result).children(".alert-message"));
        }
  });
}

function testConnection(item) {
  var target = $(item).attr('data-url');
  var args = {}
  args["provider"] = attribute_hash(['name', 'provider', 'url', 'user', 'password']);

  $('#test_connection_indicator').show();
  $.ajax({
    type:'put',
    url:target,
    data:args,
    success:function (result) {
      $('#compute_connection').html($(result).children("#compute_connection"));
      $('#compute_connection').prepend($(result).children(".alert-message"));
    },
    complete:function (result) {
      $('#test_connection_indicator').hide();
      $('[rel="twipsy"]').twipsy();
    }
  });
}

function ovirt_hwpSelected(item){
  var hwp = $(item).val();
  var url = $(item).attr('data-url');

  $('#hwp_indicator').show();
  $.ajax({
      type:'post',
      url: url,
      data:'hwp_id=' + hwp,
      success: function(result){
        $('[id$=_memory]').val(result.memory);
        $('[id$=_cores]').val(result.cores);
        $('#network_interfaces').children('.fields').remove();
        $.each(result.interfaces, function() {add_network_interface(this);})
      },
      complete: function(result){
        $('#hwp_indicator').hide();
        $('[rel="twipsy"]').twipsy();
      }
    })
}
// fill in the template interfaces.
function add_network_interface(item){
  var new_id = add_child_node($(".add_nested_fields"));
  $('[id$='+new_id+'_name]').val(item.name);
  $('[id$='+new_id+'_network]').val(item.network);
}

function ovirt_clusterSelected(item){
  var cluster = $(item).val();
  var url = $(item).attr('data-url');
  $('#cluster_indicator').show();
  $.ajax({
      type:'post',
      url: url,
      data:'cluster_id=' + cluster,
      success: function(result){
        var network_options = $("[id$=_network]").empty();
        $.each(result, function() {
          network_options.append($("<option />").val(this.id).text(this.name));
        });
      },
      complete: function(result){
        $('#cluster_indicator').hide();
        $('[rel="twipsy"]').twipsy();
      }
    })
}
