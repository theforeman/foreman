function add_puppet_class(item){
  var id = $(item).attr('data-class-id');
  var content = $(item).parent().clone();
  content.attr('title', 'Click to remove this class');
  content.attr('id', 'selected_puppetclass_'+ id);
  content.append("<input id='host_puppetclass_ids_' name='host[puppetclass_ids][]' type='hidden' value=" +id+ ">");

  var link = content.children().first();
  link.attr('onclick', 'remove_puppet_class(this)');
  link.removeClass('ui-icon-plus').addClass('ui-icon-minus');

  $('#selected_classes').append(content)

  $("#selected_puppetclass_"+ id).show('highlight', 5000);
  $("#puppetclass_"+ id).hide();
}

function remove_puppet_class(item){
  var id = $(item).attr('data-class-id');
  $('#puppetclass_' + id ).show();
  $('#selected_puppetclass_' + id).remove();

  return false;
}

function hostgroup_changed(element) {
  var host_id = $(element).attr('data-host-id');
  var hostgroup_id = $('*[id*=hostgroup_id]').attr('value');
  if (hostgroup_id == undefined) hostgroup_id = $('#hostgroup_parent_id').attr('value');
  $('#hostgroup_indicator').show();
  if (!host_id){ // a new host
    $.ajax({
      type:'post',
      url:'/hosts/process_hostgroup',
      data:'hostgroup_id=' + hostgroup_id,
      complete: function(request){
         $('#hostgroup_indicator').hide();
      }
    })
  } else { // edit host
    update_puppetclasses(element);
  }
}

function update_puppetclasses(element) {
  var host_id = $(element).attr('data-host-id');
  var env_id = $('*[id*=environment_id]').attr('value');
  var hostgroup_id = $('*[id*=hostgroup_id]').attr('value');
  if (env_id == "") return false;
  $.ajax({
    type:'post',
    url:'/hosts/hostgroup_or_environment_selected',
    data:'host_id=' + host_id + '&hostgroup_id=' + hostgroup_id + '&environment_id=' + env_id,
    success: function(request) {
      $('#puppet_klasses').html(request);
    },
    complete: function(request) {
      $('#hostgroup_indicator').hide();
    }
  })
}
function hypervisor_selected(element){
  var hypervisor_id = $(element).val();
  $('#vm_indicator').show();
  $.ajax({
    data:'hypervisor_id=' + hypervisor_id,
    type:'post',
    url:'/hosts/hypervisor_selected',
    complete: function(request){
      $('#vm_indicator').hide();
      if ($('#host_name').size() == 0 ) $('#host_powerup').parent().parent().remove();
    }
  })
}

function subnet_selected(element){
  var subnet_id = $(element).val();
  if (subnet_id == '' || $('#host_ip').size() == 0) return false;
  $('#subnet_indicator').show();
  $.ajax({
    data:'subnet_id=' + subnet_id,
    type:'post',
    url:'/subnets/freeip',
    complete: function(request){$('#subnet_indicator').hide()}
  })
}

function domain_selected(element){
  var domain_id = $(element).val();
  $.ajax({
    data:'domain_id=' + domain_id,
    type:'post',
    url:'/hosts/domain_selected',
    success: function(request) {
      $('#subnet_select').html(request);
    }
  })
}

function architecture_selected(element){
  var architecture_id = $(element).val();
  $.ajax({
    data:'architecture_id=' + architecture_id,
    type:'post',
    url:'/hosts/architecture_selected',
    success: function(request) {
      $('#os_select').html(request);
    }
  })
}

function os_selected(element){
  var operatingsystem_id = $(element).val();
  $.ajax({
    data:'operatingsystem_id=' + operatingsystem_id,
    type:'post',
    url:'/hosts/os_selected',
    success: function(request) {
      $('#media_select').html(request);
    }
  })
}
