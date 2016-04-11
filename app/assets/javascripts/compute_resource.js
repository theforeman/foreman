// AJAX load vm listing
$(function() {
  $('#vms, #images_list').each(function() {
    var url = $(this).attr('data-url');
    $(this).load(url + ' table', function(response, status, xhr) {
      if (status == "error") {
        $(this).closest(".tab-content").find("#spinner").html(Jed.sprintf(__("There was an error listing VMs: %(status)s %(statusText)s"), {status: xhr.status, statusText: xhr.statusText}));
      }
      else {
        activateDatatables();
      }
    });
  });
});

function providerSelected(item)
{
  compute_connection = $('#compute_connection');
  var provider = $(item).val();
  if(provider == "") {
    compute_connection.hide();
    $("[type=submit]").attr("disabled",true);
    return false;
  }
  $("[type=submit]").attr("disabled",false);
  var url = $(item).attr('data-url');
  var data = 'provider=' + provider;
  compute_connection.show();
  compute_connection.load(url + ' div#compute_connection', data, function () {
    password_caps_lock_hint()
  });
}

function testConnection(item) {
  var cr_id = $("form").data('id');
  var password = $("input#compute_resource_password").val();
  $('.tab-error').removeClass('tab-error');
  $('#test_connection_indicator').show();
  $.ajax({
    type:'put',
    url: $(item).attr('data-url'),
    data: $('form').serialize() + '&cr_id=' + cr_id,
    success:function (result) {
      var res = $('<div>' + result + '</div>');
      $('#compute_connection').html(res.find("#compute_connection"));
      $('#compute_connection').prepend(res.find(".alert"));
      if (!$("#compute_resource_provider").prop('disabled')) {
        $("#compute_resource_password").prop('disabled', false);
      }
      if (!/alert-danger/i.test(result)) {
        notify("<p>" + __("Test connection was successful") + "</p>", 'success')
      }
    },
    complete:function (result) {
      //we need to restore the password field as it is not sent back from the server.
      $("input#compute_resource_password").val(password);
      reloadOnAjaxComplete('#test_connection_indicator');
    }
  });
}

function ovirt_templateSelected(item){
  var template = $(item).val();
  if (template) {
    var url = $(item).attr('data-url');
    tfm.tools.showSpinner();
    $.ajax({
      type:'post',
      url: url,
      data:'template_id=' + template,
      success: function(result){
        $('[id$=_memory]').val(result.memory);
        $('[id$=_cores]').val(result.cores);
        $('#network_interfaces').children('.fields').remove();
        $.each(result.interfaces, function() {add_network_interface(this);});
        $('#storage_volumes').children('.fields').remove();
        $.each(result.volumes, function() {add_volume(this);});
      },
      complete: function(){
        reloadOnAjaxComplete(item);
      }
    })
  }
}

// fill in the template interfaces.
function add_network_interface(item){
  var nested_fields = $("#network_interfaces .add_nested_fields");
  // no network interfaces update when the network editing is not allowed by the compute resource
  if (nested_fields.length > 0) {
      var new_id = add_child_node(nested_fields);
      $('[id$='+new_id+'_name]').val(item.name);
      $('[id$='+new_id+'_network]').val(item.network);
  }
}

// fill in the template volumes.
function add_volume(item){
  var new_id = add_child_node($("#storage_volumes .add_nested_fields"));
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
  $('[id$=_bootable_true]').prop('checked', false);
  if ($disabled.length > 0){
    $disabled.prop('checked', true);
  } else {
    $(item).prop('checked', true);
  }
}

function ovirt_clusterSelected(item){
  var cluster = $(item).val();
  var url = $(item).attr('data-url');
  tfm.tools.showSpinner();
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
      complete: function(){
        reloadOnAjaxComplete(item);
      }
    })
}

function ovirt_datacenterSelected(item){
  testConnection($('#test_connection_button'));
}

function libvirt_network_selected(item){
  selected = $(item).val();
  dropdown = $(item).closest('select');
  bridge   = $(item).parentsUntil('.fields').parent().find('#bridge');
  nat      = $(item).parentsUntil('.fields').parent().find('#nat');
  switch (selected) {
    case '':
      disable_libvirt_dropdown(bridge);
      disable_libvirt_dropdown(nat);
      break;
    case 'network':
      disable_libvirt_dropdown(bridge);
      enable_libvirt_dropdown(nat);
      break;
    case 'bridge':
      disable_libvirt_dropdown(nat);
      enable_libvirt_dropdown(bridge);
      break;
  }
  return false;
}

function disable_libvirt_dropdown(item){
  item.hide();
  item.attr("disabled",true);
}

function enable_libvirt_dropdown(item){
  item.attr("disabled",false);
  item.find(':input').attr('disabled',false)
  item.show();
}

function libvirt_image_selected(item){
  var template = $(item).val();
  if (template) {
    var url = $(item).attr('data-url');
    tfm.tools.showSpinner();
    $.ajax({
      type:'post',
      url: url,
      data:'template_id=' + template,
      success: function(result){
        capacity = $('#storage_volumes').children('.fields').find('[id$=capacity]')[0];
        if (parseInt(capacity.value.slice(0, -1), 10) < parseInt(result.capacity, 10))
          capacity.value = result.capacity + 'G';
        $('#storage_volumes').children('.fields').find('[id$=format_type]')[0].value = 'qcow2';
      },
      complete: function(){
        reloadOnAjaxComplete(item);
      }
    })
  }
}

function ec2_vpcSelected(form){
  sg_select = $('select.security_group_ids')
  sg_select.empty();
  security_groups = jQuery.parseJSON( sg_select.attr('data-security-groups') );
  subnets = jQuery.parseJSON( sg_select.attr('data-subnets') );
  if(form.value != ''){
    vpc=subnets[form.value]
  } else {
    vpc = {'vpc_id': 'ec2', 'subnet_name': 'ec2'};
  }
  for(sg in security_groups[vpc.vpc_id]){
     sg_select.append($('<option />').val(security_groups[vpc.vpc_id][sg].group_id).text(security_groups[vpc.vpc_id][sg].group_name+' - '+vpc.subnet_name));
  }
  sg_select.multiSelect("refresh");
}

function capacity_edit(element) {
  var buttons = $(element).closest('.fields').find('button[name=allocation_radio_btn].btn.active');
  if (buttons.length > 0 && $(buttons[0]).text() == 'Full') {
    var allocation = $(element).closest('.fields').find('[id$=allocation]')[0];
    allocation.value = element.value;
  }
  return false;
}

function allocation_switcher(element, action) {
  var previous = $(element).parent().find('.active');
  previous.removeClass('active');

  var allocation = $(element).closest('.fields').find('[id$=allocation]')[0];
  if (action == 'None') {
    $(allocation).attr('readonly', 'readonly');
    allocation.value = '0G';
  } else if (action == 'Size') {
    $(allocation).removeAttr('readonly');
    allocation.value = '';
    $(allocation).focus();
  } else if (action == 'Full') {
    $(allocation).attr('readonly', 'readonly');
    var capacity = $(element).closest('.fields').find('[id$=capacity]')[0];
    allocation.value = capacity.value;
  }

  $(element).button('toggle');
  return false;
}

function vsphereGetResourcePools(item) {
  var data = {cluster_id: $(item).val()};
  var url = $(item).data('url');
  tfm.tools.showSpinner();
  selectbox = $('*[id*=resource_pool]');
  selectbox.select2('destroy').empty();
  $.ajax({
    type: 'get',
    url: url,
    data: data,
    complete: function() { tfm.tools.hideSpinner();},
    success: function(request) {
      for (var i = 0; i < request.length; i++) {
        var option = request[i].name;
        $('<option>').text(option).val(option).appendTo(selectbox);
      }
      $(selectbox).select2();
    }
  })
}

function vsphereStoragePodSelected(item) {
  selected = $(item).val();
  datastore = $('select[id*=datastore]')
  if(!selected || 0 === selected.length) {
    enable_vsphere_dropdown(datastore);
  } else {
    disable_vsphere_dropdown(datastore);
  }
  return false;
}

function vsphereStoragePodLoad() {
  items = $('select[id*=storage_pod]');
  if(items.length < 1) {
    return false;
  }
  items.each(function() {
    selected = $(this).val();
    if(selected || ! (0 === selected.length)) {
      datastore = $('select[id*=datastore]');
      disable_vsphere_dropdown(datastore);
    }
  });
  return false;
}

$(document).on('ContentLoad', function(){vsphereStoragePodLoad()});

function disable_vsphere_dropdown(item){
  item.attr("disabled", true);
}

function enable_vsphere_dropdown(item){
  item.attr("disabled", false);
}
