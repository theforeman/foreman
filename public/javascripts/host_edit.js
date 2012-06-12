function computeResourceSelected(item){
  var compute = $(item).val();
  var attrs = attribute_hash(['architecture_id', 'compute_resource_id', 'operatingsystem_id']);
  var label = $(item).children(":selected").text();
  if(compute=='') { //Bare Metal
    $('#mac_address').show();
    $('#bmc').show();
    $("#model_name").show();
    $('#compute_resource').empty();
    $('#vm_details').empty();
    $("#libvirt_tab").hide();
    $('#host_hypervisor_id').val("");
    $("#compute_resource_tab").hide();
    update_capabilities('build');
  }else if(label == 'Libvirt'){
    $('#mac_address').hide();
    $('#bmc').hide();
    $("#model_name").show();
    $("#libvirt_tab").show();
    $("#compute_resource_tab").hide();
    $('#compute_resource').empty();
    $(item).children(":selected").val("");
    update_capabilities('build');
  }
  else {
    $('#mac_address').hide();
    $('#bmc').hide();
    $("#libvirt_tab").hide();
    $("#model_name").hide();
    $('#host_hypervisor_id').val("");
    $("#compute_resource_tab").show();
    $('#vm_details').empty();
    var url = $(item).attr('data-url');
    $.ajax({
      type:'post',
      url: url,
      data: attrs,
      success: function(result){
        $('#compute_resource').html(result);
        update_capabilities($('#capabilities').val());
      }
    })
  }
}


function update_capabilities(capabilities){
  var build = (/build/i.test(capabilities));
  var image = (/image/i.test(capabilities));
  if (build){
    $('#manage_network').show();
    $('#host_provision_method_build').click();
  } else {
    $('#manage_network').hide();
    $('#host_provision_method_image').click();
  }
  if(build && image){
    $('#provisioning_method').show();
  }else{
    $('#provisioning_method').hide();
  }
  $('#image_provisioning').empty();
  $('#image_selection').appendTo($('#image_provisioning'));
  update_provisioning_image();
}

var stop_pooling;

function submit_host(form){
  var url = form.attr("action");
  $('#host_submit').attr('disabled', true);
  stop_pooling = false;
  $("body").css("cursor", "progress");
  clear_errors();
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
        $("#host-progress").hide();
        $('#content').replaceWith($("#content", response));
        onContentLoad();
        onHostEditLoad();
      }
    },
    error: function(response){
      $('#content').html(response.responseText);
    },
    complete: function(){
      stop_pooling = true;
      $("body").css("cursor", "auto");
      $('#host_submit').attr('disabled', false);
    }
  });
  return false;
}

function clear_errors(){
  $('.error').children().children('.help-inline').remove();
  $('.error').removeClass('error');
  $('.tab-error').removeClass('tab-error');
  $('.alert-error').remove();
}

function animate_progress(){
  if (stop_pooling == true) return;
  setTimeout(function() {
    var task_id = $('#host_progress_report_id').val();
    $.get('/tasks/' + task_id, function (response){
       update_progress(response);
       animate_progress();
    })
  }, 1600);
}

function update_progress(data){
  var task_list_size = $('p',data).size();
  if (task_list_size == 0 || stop_pooling == true) return;

  var done_tasks = $('.icon-check',data).size();
  var failed_tasks = $('.icon-remove',data).size();
  var $progress = $('.progress');

  $("#host-progress").show();
  if(failed_tasks > 0) {
    $progress.removeClass('progress-success').addClass('progress-danger');
  }else{
    $progress.removeClass('progress-danger').addClass('progress-success');
  }
  $('.bar').width(done_tasks/task_list_size *$progress.width());
  $('#tasks_progress').replaceWith(data);
}

function filter_puppet_classes(item){
  var term = $(item).val().trim();
  $('li.puppetclass.hide').addClass('hide-me');
  if (term.length > 0) {
    $('li.puppetclass').removeClass('filter-marker').hide();
    $('li.puppetclass:not(.hide-me, .selected-marker) span:contains('+term+')').parent('li').addClass('filter-marker').show();
  } else{
    $('li.puppetclass:not(.hide-me, .selected-marker)').addClass('filter-marker').show();
  }
  var groups = $('li.filter-marker').closest('.puppetclass_group');
  $('.puppetclass_group').hide();
  groups.show();
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
  $("#puppetclass_"+ id).addClass('selected-marker').hide();
}

function remove_puppet_class(item){
  var id = $(item).attr('data-class-id');
  $('#puppetclass_' + id).removeClass('selected-marker').show();
  $('#puppetclass_' + id).closest('.puppetclass_group').show();
  $('#selected_puppetclass_' + id).children('a').tooltip('hide');
  $('#selected_puppetclass_' + id).remove();

  return false;
}

function hostgroup_changed(element) {
  var host_id = $(element).attr('data-host-id');
  var url = $(element).attr('data-url');
  var attrs   = attribute_hash(['hostgroup_id', 'compute_resource_id']);
  if (attrs["hostgroup_id"] == undefined) attrs["hostgroup_id"] = $('#hostgroup_parent_id').attr('value');
  $('#hostgroup_indicator').show();
  if (!host_id){ // a new host
    $.ajax({
      type:'post',
      url: url,
      data:attrs,
      complete: function(){
        $('#hostgroup_indicator').hide();
        $('[rel="twipsy"]').tooltip();
        update_provisioning_image();
      }
    })
  } else { // edit host
    update_puppetclasses(element);
  }
}

function update_puppetclasses(element) {
  var host_id = $(element).attr('data-host-id');
  var env_id = $('*[id*=environment_id]').attr('value');
  var url = $(element).attr('data-url');
  var hostgroup_id = $('*[id*=hostgroup_id]').attr('value');
  if (env_id == "") return;
  $.ajax({
    type: 'post',
    url:  url,
    data:'host_id=' + host_id + '&hostgroup_id=' + hostgroup_id + '&environment_id=' + env_id,
    success: function(request) {
      $('#puppet_klasses').html(request);
    },
    complete: function() {
      $('#hostgroup_indicator').hide();
      $('[rel="twipsy"]').tooltip();
    }
  })
}
function hypervisor_selected(element){
  var hypervisor_id = $(element).val();
  var url = $(element).attr('data-url');
  $('#vm_indicator').show();
  $.ajax({
    data:'hypervisor_id=' + hypervisor_id,
    type:'post',
    url: url,
    complete: function(){
      $('#vm_indicator').hide();
      if ($('#host_name').size() == 0 ) $('#host_powerup').parent().parent().remove();
    }
  })
}

function subnet_selected(element){
  var subnet_id = $(element).val();
  if (subnet_id == '' || $('#host_ip').size() == 0) return;
  // We do not query the proxy if the host_ip field is filled in and contains an
  // IP that is in the selected subnet
  var drop_text = $(element).children(":selected").text();
  if (drop_text.length !=0 && drop_text.search(/^.+ \([0-9\.\/]+\)/) != -1) {
    var details = drop_text.replace(/^[^(]+\(/, "").replace(")","").split("/");
    if (subnet_contains(details[0], details[1], $('#host_ip').val()))
      return;
  }
  var attrs = attribute_hash(["subnet_id", "host_mac"]);
  $('#subnet_indicator').show();
  $.ajax({
    data: attrs,
    type:'post',
    url:'/subnets/freeip',
    complete: function(){$('#subnet_indicator').hide()}
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
  for(var i=0;i<=3;i++){
    integer = (integer * 256) + parseInt(nibble[i]);
  }
  return integer;
}

function domain_selected(element){
  var domain_id = $(element).val();
  var url = $(element).attr('data-url');
  $.ajax({
    data:'domain_id=' + domain_id,
    type:'post',
    url: url,
    success: function(request) {
      $('#subnet_select').html(request);
    }
  })
}

function architecture_selected(element){
  var architecture_id = $(element).val();
  var url = $(element).attr('data-url');
  $.ajax({
    data:'architecture_id=' + architecture_id,
    type:'post',
    url: url,
    success: function(request) {
      $('#os_select').html(request);
    }
  })
}

function os_selected(element){
  var os_id = $(element).val();
  var url = $(element).attr('data-url');
  $.ajax({
    data:'operatingsystem_id=' + os_id,
    type:'post',
    url: url,
    success: function(request) {
      $('#media_select').html(request);
    }
  });
  update_provisioning_image();
}
function update_provisioning_image(){
  var compute_id = $('[id$="_compute_resource_id"]').val();
  var arch_id = $('[id$="_architecture_id"]').val();
  var os_id = $('[id$="_operatingsystem_id"]').val();
  if((compute_id == undefined) || (compute_id == "") || (arch_id == "") || (os_id == "")) return;
  var term = 'operatingsystem=' + os_id + ' architecture=' + arch_id;
  var image_options = $("[id$=compute_attributes_image_id]").empty();
  $.ajax({
      data:'search=' + encodeURIComponent(term),
      type:'get',
      url:'/compute_resources/'+compute_id+'/images',
      dataType: 'json',
      success: function(result) {
        $.each(result, function() {
          image_options.append($("<option />").val(this.image.uuid).text(this.image.name));
        });
        if (image_options.find('option').length > 0)
          image_options.attr('disabled', false);
      }
    })
}

function medium_selected(element){
  var url = $(element).attr('data-url');
  var type = $(element).attr('data-type');
  var obj = (type == "hosts" ? "host" : "hostgroup");
  var attrs = {};
  attrs[obj] = attribute_hash(['medium_id', 'operatingsystem_id', 'architecture_id']);
  attrs[obj]["use_image"] = $('*[id*=use_image]').attr('checked') == "checked";
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    success: function(request) {
      $('#image_details').html(request);
    }
  })
}

function use_image_selected(element){
  var url = $(element).attr('data-url');
  var type = $(element).attr('data-type');
  var obj = (type == "hosts" ? "host" : "hostgroup");
  var attrs = {};
  attrs[obj] = attribute_hash(['medium_id', 'operatingsystem_id', 'architecture_id', 'model_id']);
  attrs[obj]['use_image'] = ($(element).attr('checked') == "checked");
  $.ajax({
    data: attrs,
    type: 'post',
    url:  url,
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

  $('#host_provision_method_build').on('click', function(){
    $('#network_provisioning').show();
    $('#image_provisioning').hide();
  });
  $('#host_provision_method_image').on('click', function(){
    $('#network_provisioning').hide();
    $('#image_provisioning').show();
  });

  $('#image_selection').appendTo($('#image_provisioning'));
}
