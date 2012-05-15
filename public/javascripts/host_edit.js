function computeResourceSelected(item){
  var compute = $(item).val();
  var label = $(item).children(":selected").text();
  if(compute=='') { //Bare Metal
    $('#mac_address').show();
    $('#compute_resource').empty();
    $('#vm_details').empty();
    $("#libvirt_tab").hide();
    $('#host_hypervisor_id').val("");
    $("#compute_resource_tab").hide();
  }else if(label == 'Libvirt'){
    $('#mac_address').hide();
    $("#libvirt_tab").show();
    $("#compute_resource_tab").hide();
    $('#compute_resource').empty();
    $(item).children(":selected").val("");
  }
  else {
    $('#mac_address').hide();
    $("#libvirt_tab").hide();
    $('#host_hypervisor_id').val("");
    $("#compute_resource_tab").show();
    $('#vm_details').empty();
    var url = $(item).attr('data-url');
    $.ajax({
      type:'post',
      url: url,
      data:'compute_resource_id=' + compute,
      success: function(result){
        $('#compute_resource').html(result);
      }
    })
  }
}

var stop_pooling;

function submit_host(form){
  var url = form.attr("action");
  stop_pooling = false;
  $("body").css("cursor", "progress");
  animate_progress();

  $.ajax({
    type:'POST',
    url: url,
    data: form.serialize(),
    success: function(response){
      if(response.redirect){
        window.location.replace(response.redirect);
      }
      else{
        $("#host-progress-modal").modal('hide');
        $('#content').replaceWith($("#content", response));
        onHostEditLoad();
        onContentLoad();
      }
    },
    complete: function(response){
      stop_pooling = true;
      $("body").css("cursor", "auto");
      $("#host-progress-modal").modal('hide');
    }
  });
  return false;
}

function animate_progress(){
  if (stop_pooling == true) return;
  setTimeout(function() {
    var task_id = $('#host_queuename').val();
    $.get('/tasks/' + task_id, function (response){
       update_progress(response);
       animate_progress();
    })
  }, 1600);
}

function update_progress(data){
  var all = $('p',data).size();
  if (all == 0 || stop_pooling == true) return;
  var done = $('.icon-check',data).size();
  $("#host-progress-modal").modal();
  if($('.icon-remove',data).size() > 0) {
    $('.progress').removeClass('progress-success');
    $('.progress').addClass('progress-danger');
  }else{
    $('.progress').removeClass('progress-danger');
    $('.progress').addClass('progress-success');
  }
  $('.bar').width(done/all *400);
  $('#tasks_progress').replaceWith(data);
}

function add_puppet_class(item){
  var id = $(item).attr('data-class-id');
  var type = $(item).attr('data-type');
  var content = $(item).parent().clone();
  content.attr('id', 'selected_puppetclass_'+ id);
  content.append("<input id='" + type +"_puppetclass_ids_' name='" + type +"[puppetclass_ids][]' type='hidden' value=" +id+ ">");
  content.children('span').tooltip();

  var link = content.children('a');
  link.attr('onclick', 'remove_puppet_class(this)');
  link.attr('data-original-title', 'Click to undo adding this class');
  link.removeClass('ui-icon-plus').addClass('ui-icon-minus').tooltip();

  $('#selected_classes').append(content);

  $("#selected_puppetclass_"+ id).show('highlight', 5000);
  $("#puppetclass_"+ id).hide();
}

function remove_puppet_class(item){
  var id = $(item).attr('data-class-id');
  $('#puppetclass_' + id ).show();
  $('#selected_puppetclass_' + id).children('a').tooltip('hide');
  $('#selected_puppetclass_' + id).remove();

  return false;
}

function hostgroup_changed(element) {
  var host_id = $(element).attr('data-host-id');
  var type    = $(element).attr('data-type');
  var attrs   = attribute_hash(['hostgroup_id', 'compute_resource_id']);
  if (attrs["hostgroup_id"] == undefined) attrs["hostgroup_id"] = $('#hostgroup_parent_id').attr('value');
  $('#hostgroup_indicator').show();
  if (!host_id){ // a new host
    $.ajax({
      type:'post',
      url:'/' + type + '/process_hostgroup',
      data:attrs,
      complete: function(request){
        $('#hostgroup_indicator').hide();
        $('[rel="twipsy"]').tooltip();
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
  url = (type == "hosts") ? url + '/hostgroup_or_environment_selected' : url + '/environment_selected';
  $.ajax({
    type: 'post',
    url:  url,
    data:'host_id=' + host_id + '&hostgroup_id=' + hostgroup_id + '&environment_id=' + env_id,
    success: function(request) {
      $('#puppet_klasses').html(request);
    },
    complete: function(request) {
      $('#hostgroup_indicator').hide();
      $('[rel="twipsy"]').tooltip();
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
  // We do not query the proxy if the host_ip field is filled in and contains an
  // IP that is in the selected subnet
  var drop_text = $(element).children(":selected").text();
  if (drop_text.length !=0 && drop_text.search(/^.+ \([0-9\.\/]+\)/) != -1) {
    var details = drop_text.replace(/^[^(]+\(/, "").replace(")","").split("/");
    if (subnet_contains(details[0], details[1], $('#host_ip').val()))
      return false;
  }
  var attrs = attribute_hash(["subnet_id", "host_mac"]);
  $('#subnet_indicator').show();
  $.ajax({
    data: attrs,
    type:'post',
    url:'/subnets/freeip',
    complete: function(request){$('#subnet_indicator').hide()}
  })
}

function subnet_contains(number, cidr, ip){
  var int_ip     = _to_int(ip);
  var int_number = _to_int(number);
  var shift      = 32 - parseInt(cidr);
  return (int_ip >> shift == int_number >> shift);
}

function _to_int(str){
  var nibble = str.split(".");
  var integer = 0;
  for(i=0;i<=3;i++){
    integer = (integer * 256) + parseInt(nibble[i]);
  }
  return integer;
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

function medium_selected(element){
  var type = $(element).attr('data-type');
  var obj = (type == "hosts" ? "host" : "hostgroup");
  var attrs = {};
  attrs[obj] = attribute_hash(['medium_id', 'operatingsystem_id', 'architecture_id']);
  attrs[obj]["use_image"] = $('*[id*=use_image]').attr('checked') == "checked";
  $.ajax({
    data: attrs,
    type:'post',
    url:'/' + type + '/medium_selected',
    success: function(request) {
      $('#image_details').html(request);
    }
  })
}

function use_image_selected(element){
  var type = $(element).attr('data-type');
  var obj = (type == "hosts" ? "host" : "hostgroup");
  var attrs = {};
  attrs[obj] = attribute_hash(['medium_id', 'operatingsystem_id', 'architecture_id', 'model_id']);
  attrs[obj]['use_image'] = ($(element).attr('checked') == "checked");
  $.ajax({
    data: attrs,
    type: 'post',
    url:  '/' + type + '/use_image_selected',
    success: function(response) {
      var field = $('*[id*=image_file]');
      if (attrs[obj]["use_image"]) {
        if (field.val() == "") field.val(response["image_file"]);
      } else
        field.val("");

      field.attr("disabled", !attrs[obj]["use_image"]);
    }
  });
}

$(function () {
  onHostEditLoad();
});

function onHostEditLoad(){
  $("#host-conflicts-modal").modal({show: "true", backdrop: "static"});
   $('#host-conflicts-modal').click(function(){
     $('#host-conflicts-modal').modal('hide');
   });
  var $form = $("[data-submit='progress_bar']");
  $form.on('submit', function(){
    submit_host($form);
    return false;
  });
}
