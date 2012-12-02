// AJAX load vm listing
$(function() {
  $('#vms, #images_list').each(function() {
    var url = $(this).attr('data-url');
    $(this).load(url + ' table', function(response, status, xhr) {
      if (status == "error") {
        $(this).closest("#spinner").html("Sorry but there was an error: " + xhr.status + " " + xhr.statusText);
      }
      $('.dropdown-toggle').dropdown();
    });
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
          $('#compute_connection').html($(result).find("#compute_connection"));
          $('#compute_connection').append($(result).find(".alert-message"));
        }
  });
}

function testConnection(item) {

  $('#test_connection_indicator').show();
  $.ajax({
    type:'put',
    url: $(item).attr('data-url'),
    data: $('#new_compute_resource').serialize(),
    success:function (result) {
      $('#compute_connection').html($(result).find("#compute_connection"));
      $('#compute_connection').prepend($(result).find(".alert-message"));
    },
    complete:function (result) {
      $('#test_connection_indicator').hide();
      $('[rel="twipsy"]').tooltip();
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
        $.each(result.interfaces, function() {add_network_interface(this);});
        $('#volumes').children('.fields').remove();
        $.each(result.volumes, function() {add_volume(this);});
      },
      complete: function(result){
        $('#hwp_indicator').hide();
        $('[rel="twipsy"]').tooltip();
      }
    })
}
// fill in the template interfaces.
function add_network_interface(item){
  var new_id = add_child_node($("#network_interfaces .add_nested_fields"));
  $('[id$='+new_id+'_name]').val(item.name);
  $('[id$='+new_id+'_network]').val(item.network);
}

// fill in the template volumes.
function add_volume(item){
  var new_id = add_child_node($("#volumes .add_nested_fields"));
  disable_element($('[id$='+new_id+'_size_gb]').val(item.size_gb));
  disable_element($('[id$='+new_id+'_storage_domain]').val(item.storage_domain));
  disable_element( $('[id$='+new_id+'_bootable_true]').attr('checked', item.bootable));
  $('[id$='+new_id+'_id]').val(7);
  $('[id$='+new_id+'_storage_domain]').next().hide();
}

function disable_element(element){
  element.clone().attr('type','hidden').appendTo(element);
  element.attr('disabled', 'disabled');
}
function bootable_radio(item){
  var $disabled = $('[id$=_bootable_true]:disabled:checked:visible');
  $('[id$=_bootable_true]').attr('checked', false);
  if ($disabled.size() > 0){
    $disabled.attr('checked', true);
  } else {
    $(item).attr('checked', true);
  }
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
        var network_options = $("select[id$=_network]").empty();
        $.each(result, function() {
          network_options.append($("<option />").val(this.id).text(this.name));
        });
      },
      complete: function(result){
        $('#cluster_indicator').hide();
        $('[rel="twipsy"]').tooltip();
      }
    })
}
