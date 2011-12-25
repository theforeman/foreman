function add_puppet_class(item){
  var id = $(item).attr('data-class-id');
  var type = $(item).attr('data-type');
  var content = $(item).parent().clone();
  content.attr('id', 'selected_puppetclass_'+ id);
  content.append("<input id='" + type +"_puppetclass_ids_' name='" + type +"[puppetclass_ids][]' type='hidden' value=" +id+ ">");
  content.children('span').twipsy();

  var link = content.children('a');
  link.attr('onclick', 'remove_puppet_class(this)');
  link.attr('data-original-title', 'Click to undo adding this class');
  link.removeClass('ui-icon-plus').addClass('ui-icon-minus').twipsy();

  $('#selected_classes').append(content)

  $("#selected_puppetclass_"+ id).show('highlight', 5000);
  $("#puppetclass_"+ id).hide();
}

function remove_puppet_class(item){
  var id = $(item).attr('data-class-id');
  $('#puppetclass_' + id ).show();
  $('#selected_puppetclass_' + id).children('a').twipsy('hide');
  $('#selected_puppetclass_' + id).remove();

  return false;
}

function hostgroup_changed(element) {
  var host_id = $(element).attr('data-host-id');
  var hostgroup_id = $('*[id*=hostgroup_id]').attr('value');
  var type = $(element).attr('data-type');
  if (hostgroup_id == undefined) hostgroup_id = $('#hostgroup_parent_id').attr('value');
  $('#hostgroup_indicator').show();
  if (!host_id){ // a new host
    $.ajax({
      type:'post',
      url:'/' + type + '/process_hostgroup',
      data:'hostgroup_id=' + hostgroup_id,
      complete: function(request){
         $('#hostgroup_indicator').hide();
         $('[rel="twipsy"]').twipsy();
      }
    })
  } else { // edit host
    update_puppetclasses(element);
  }
}

function update_puppetclasses(element) {
  var host_id = $(element).attr('data-host-id');
  var env_id = $('*[id*=environment_id]').attr('value');
  var type = $(element).attr('data-type');
  var hostgroup_id = $('*[id*=hostgroup_id]').attr('value');
  if (env_id == "") return false;
  var url = '/' + type;
  url = (type == "host") ? url + '/hostgroup_or_environment_selected' : url + '/environment_selected';
  $.ajax({
    type: 'post',
    url:  url,
    data:'host_id=' + host_id + '&hostgroup_id=' + hostgroup_id + '&environment_id=' + env_id,
    success: function(request) {
      $('#puppet_klasses').html(request);
    },
    complete: function(request) {
      $('#hostgroup_indicator').hide();
      $('[rel="twipsy"]').twipsy();
    }
  })
}
function hypervisor_selected(element){
  var hypervisor_id = $(element).val();
  var type = $(element).attr('data-type');
  $('#vm_indicator').show();
  $.ajax({
    data:'hypervisor_id=' + hypervisor_id,
    type:'post',
    url:'/' + type + '/hypervisor_selected',
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
  var type = $(element).attr('data-type');
  $.ajax({
    data:'domain_id=' + domain_id,
    type:'post',
    url:'/' + type +'/domain_selected',
    success: function(request) {
      $('#subnet_select').html(request);
    }
  })
}

function architecture_selected(element){
  var architecture_id = $(element).val();
  var type = $(element).attr('data-type');
  $.ajax({
    data:'architecture_id=' + architecture_id,
    type:'post',
    url:'/' + type + '/architecture_selected',
    success: function(request) {
      $('#os_select').html(request);
    }
  })
}

function os_selected(element){
  var operatingsystem_id = $(element).val();
  var type = $(element).attr('data-type');
  $.ajax({
    data:'operatingsystem_id=' + operatingsystem_id,
    type:'post',
    url:'/' + type + '/os_selected',
    success: function(request) {
      $('#media_select').html(request);
    }
  })
}
