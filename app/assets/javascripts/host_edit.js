function computeResourceSelected(item){
  var compute = $(item).val();
  if(compute=='') { //Bare Metal
    $('#mac_address').show();
    $("#model_name").show();
    $('#compute_resource').empty();
    $('#vm_details').empty();
    $("#compute_resource_tab").hide();
    update_capabilities('build');
  }
  else
  {
    $('#mac_address').hide();
    $("#model_name").hide();
    $("#compute_resource_tab").show();
    $('#vm_details').empty();
    var data = $('form').serialize().replace('method=put', 'method=post');
    $('#compute_resource').html(spinner_placeholder(_('Loading virtual machine information ...')));
    $('#compute_resource_tab a').removeClass('tab-error');
    $(item).indicator_show();
    var url = $(item).attr('data-url');
    $.ajax({
      type:'post',
      url: url,
      data: data,
      complete: function(){$(item).indicator_hide()},
      error: function(jqXHR, status, error){
        $('#compute_resource').html(Jed.sprintf(_("Error loading virtual machine information: %s"), error));
        $('#compute_resource_tab a').addClass('tab-error');
      },
      success: function(result){
        $('#compute_resource').html(result);
        if ($('#compute_resource').find('.alert-error').length > 0) $('#compute_resource_tab a').addClass('tab-error');
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
  var url = window.location.pathname.replace(/\/edit$|\/new$/,'');
  if(/\/clone$/.test(window.location.pathname)){ url = foreman_url('/hosts'); }
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
  $('.puppetclass_group li.puppetclass.hide').addClass('hide-me');
  if (term.length > 0) {
    $('.puppetclass_group li.puppetclass').removeClass('filter-marker').hide();
    $('.puppetclass_group li.puppetclass:not(.hide-me, .selected-marker) span:contains('+term+')').parent('li').addClass('filter-marker').show();
  } else{
    $('.puppetclass_group li.puppetclass:not(.hide-me, .selected-marker)').addClass('filter-marker').show();
  }
  var groups = $('li.filter-marker').closest('.puppetclass_group');
  $('.puppetclass_group').hide();
  groups.show();
}


function add_puppet_class(item){
  var id = $(item).attr('data-class-id');
  var type = $(item).attr('data-type');
  $(item).tooltip('hide');
  var content = $(item).parent().clone();
  content.attr('id', 'selected_puppetclass_'+ id);
  content.append("<input id='" + type +"_puppetclass_ids_' name='" + type +"[puppetclass_ids][]' type='hidden' value=" +id+ ">");
  content.children('span').tooltip();

  var link = content.children('a');
  link.attr('onclick', 'remove_puppet_class(this)');
  link.attr('data-original-title', _('Click to undo adding this class'));
  link.removeClass('icon-plus-sign').addClass('icon-remove-sign').tooltip();

  $('#selected_classes').append(content);

  $("#selected_puppetclass_"+ id).show('highlight', 5000);
  $("#puppetclass_"+ id).addClass('selected-marker').hide();

  load_puppet_class_parameters(link);
}

function remove_puppet_class(item){
  var id = $(item).attr('data-class-id');
  $('#puppetclass_' + id).removeClass('selected-marker').show();
  $('#puppetclass_' + id).closest('.puppetclass_group').show();
  $('#selected_puppetclass_' + id).children('a').tooltip('hide');
  $('#selected_puppetclass_' + id).remove();
  $('#puppetclass_' + id + '_params_loading').remove();
  $('[id^="puppetclass_' + id + '_params\\["]').remove();
  $('#params-tab').removeClass("tab-error");
  if ($("#params").find('.control-group.error').length > 0) $('#params-tab').addClass('tab-error');

  return false;
}

function load_puppet_class_parameters(item) {
  var id = $(item).attr('data-class-id');
  var host_id = $("form").data('id')
  if ($('#puppetclass_' + id + '_params_loading').length > 0) return; // already loading
  if ($('[id^="#puppetclass_' + id + '_params\\["]').length > 0) return; // already loaded
  var url = $(item).attr('data-url');
  var data = $("form").serialize().replace('method=put', 'method=post');
  data = data + '&host_id=' + host_id

  if (url == undefined) return; // no parameters
  var placeholder = $('<tr id="puppetclass_'+id+'_params_loading">'+
      '<td colspan="5">' + spinner_placeholder(_('Loading parameters...')) + '</td></tr>');
  $('#inherited_puppetclasses_parameters').append(placeholder);
  $.ajax({
    url: url,
    type: 'post',
    data: data,
    success: function(result, textstatus, xhr) {
      var params = $(result);
      placeholder.replaceWith(params);
      params.find('a[rel="popover"]').popover({html: true});
      if (params.find('.error').length > 0) $('#params-tab').addClass('tab-error');
    }
  });
}

function hostgroup_changed(element) {
  var host_id = $("form").data('id')
  if (!host_id){ // a new host
    update_form(element);
  } else { // edit host
    update_puppetclasses(element);
    reload_host_params();
  }
}

function organization_changed(element) {
  update_form(element);
}

function location_changed(element) {
  update_form(element);
}


function update_form(element) {
  var url = $(element).data('url');
  var data = $('form').serialize().replace('method=put', 'method=post');
  $(element).indicator_show();
  $.ajax({
    type: 'post',
    url: url,
    data: data,
    complete: function(){  $(element).indicator_hide();},
    success: function(response) {
      $('form').replaceWith(response);
      $("[id$='subnet_id']").first().change();
      // to handle case if def process_taxonomy changed compute_resource_id to nil
      if( !$('#host_compute_resource_id').val() ) {
        $('#host_compute_resource_id').change();
      }
      onContentLoad();
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
    var details = drop_text.replace(/^.+\(/, "").replace(")","").split("/");
    if (subnet_contains(details[0], details[1], $('#host_ip').val()))
      return;
  }
  var attrs = attribute_hash(["subnet_id", "host_mac", 'organization_id', 'location_id']);
  $(element).indicator_show();
  var url = $(element).data('url');
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    complete: function(){  $(element).indicator_hide();},
    success: function(data){
      $('#host_ip').val(data.ip);
    }
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
  var attrs   = attribute_hash(['domain_id', 'organization_id', 'location_id']);
  var url = $(element).data('url');
  $(element).indicator_show();
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    complete: function(){  $(element).indicator_hide();},
    success: function(request) {
      $('#subnet_select').html(request);
      reload_host_params();
    }
  })
}

function architecture_selected(element){
  var attrs   = attribute_hash(['architecture_id', 'organization_id', 'location_id']);
  var url = $(element).attr('data-url');
  $(element).indicator_show();
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    complete: function(){  $(element).indicator_hide();},
    success: function(request) {
      $('#os_select').html(request);
    }
  })
}

function os_selected(element){
  var attrs = attribute_hash(['operatingsystem_id', 'organization_id', 'location_id']);
  var url = $(element).attr('data-url');
  $(element).indicator_show();
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    complete: function(){  $(element).indicator_hide();},
    success: function(request) {
      $('#media_select').html(request);
      reload_host_params();
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
  var image_options = $('#image_selection select').empty();
  $.ajax({
      data:'search=' + encodeURIComponent(term),
      type:'get',
      url: foreman_url('/compute_resources/'+compute_id+'/images'),
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

function override_param(item){
  var param = $(item).closest('tr');
  var n = param.find('[id^=name_]').text();
  var v = param.find('[id^=value_]').val();

  $('#parameters').find('.btn-success').click();
  var new_param = param.closest('.tab-pane').find('[id*=host_host_parameters]:visible').last().parent();
  new_param.find('[id$=_name]').val(n);
  new_param.find('[id$=_value]').val(v);
  mark_params_override();
}

function override_class_param(item){
  var param = $(item).closest('tr[id^="puppetclass_"][id*="_params\\["][id$="\\]"]');
  var id = param.attr('id').replace(/puppetclass_\d+_params\[(\d+)\]/, '$1')
  var c = param.find('[data-property=class]').text();
  var n = param.find('[data-property=name]').text();
  var v = param.find('[data-property=value]').val();
  var t = param.find('[data-property=type]').text();

  $('#puppetclasses_parameters').find('.btn-success').click();
  var new_param = param.closest('.tab-pane').find('[id*=_lookup_values]:visible').last().parent();
  new_param.find('[data-property=lookup_key_id]').val(id);
  new_param.find('[data-property=class]').val(c);
  new_param.find('[data-property=name]').val(n);
  new_param.find('[data-property=value]').val(v);
  new_param.find('[data-property=type]').val(t);
  mark_params_override();
}

function reload_host_params(){
  var host_id = $("form").data('id');
  var url = $('#params-tab').data('url');
  var data = $("[data-submit='progress_bar']").serialize().replace('method=put', 'method=post');
  data = data + '&host_id=' + host_id;
  load_with_placeholder('inherited_parameters', url, data)
}

function reload_puppetclass_params(){
  var host_id = $("form").data('id');
  var url2 = $('#params-tab').data('url2');
  var data = $("[data-submit='progress_bar']").serialize().replace('method=put', 'method=post');
  data = data + '&host_id=' + host_id
  load_with_placeholder('inherited_puppetclasses_parameters', url2, data)
}

function load_with_placeholder(target, url, data){
  if(url==undefined) return;
  var placeholder = $('<tr id="' + target + '_loading" >'+
            '<td colspan="4">'+ spinner_placeholder(_('Loading parameters...')) + '</td></tr>');
        $('#' + target + ' tbody').replaceWith(placeholder);
        $.ajax({
          type:'post',
          url: url,
          data: data,
          success:
            function(result, textstatus, xhr) {
              placeholder.closest('#' + target ).replaceWith($(result));
              mark_params_override()
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
  $('#image_selection').appendTo($('#image_provisioning'));
  $('#params-tab').on('shown', function(){mark_params_override()});
}

$(document).on('change', '#host_provision_method_build', function () {
  $('#network_provisioning').show();
  $('#image_provisioning').hide();
});

$(document).on('change', '#host_provision_method_image', function () {
  $('#network_provisioning').hide();
  $('#image_provisioning').show();
});

$(document).on('change', '.interface_domain', function () {
  interface_domain_selected(this);
});

$(document).on('change', '.interface_subnet', function () {
  interface_subnet_selected(this);
});

$(document).on('change', '.interface_type', function () {
  interface_type_selected(this);
});

function interface_domain_selected(element) {
  var domain_id = element.value;
  var subnet_options = $(element).parentsUntil('.fields').parent().find('[id$=_subnet_id]').empty();

  subnet_options.attr('disabled', true);
  if (domain_id == '') {
    subnet_options.append($("<option />").val(null).text(_('No subnets')));
    return false;
  }

  $(element).indicator_show();

  var url = $(element).attr('data-url');

  var org = $('#host_organization_id :selected').val();
  var loc = $('#host_location_id :selected').val();

  $.ajax({
    data:{domain_id: domain_id, organization_id:org, location_id: loc},
    type:'post',
    url:url,
    dataType:'json',
    success:function (result) {
      if (result.length > 1)
        subnet_options.append($("<option />").val(null).text(_('Please select')));

      $.each(result, function () {
        subnet_options.append($("<option />").val(this.subnet.id).text(this.subnet.name + ' (' + this.subnet.to_label + ')'));
      });
      if (subnet_options.find('option').length > 0) {
        subnet_options.attr('disabled', false);
        subnet_options.change();
      }
      else {
        subnet_options.append($("<option />").text(_('No subnets')));
        subnet_options.attr('disabled', true);
      }
      $(element).indicator_hide();
    }
  });
}

function interface_subnet_selected(element) {
  var subnet_id = $(element).val();
  if (subnet_id == '') return;
  var interface_ip = $(element).parentsUntil('.fields').parent().find('input[id$=_ip]')

  interface_ip.attr('disabled', true);
  $(element).indicator_show();

  // We do not query the proxy if the ip field is filled in and contains an
  // IP that is in the selected subnet
  var drop_text = $(element).children(":selected").text();
  // extracts network / cidr / ip
  if (drop_text.length != 0 && drop_text.search(/^.+ \([0-9\.\/]+\)/) != -1) {
    var details = drop_text.replace(/^.+\(/, "").replace(")","").split("/");
    var network = details[0];
    var cidr    = details[1];

    if (subnet_contains(network, cidr, interface_ip.val())) {
      interface_ip.attr('disabled', false);
      $(element).indicator_hide();
      return;
    }
  }
  var interface_mac = $(element).parentsUntil('.fields').parent().find('input[id$=_mac]')
  var url = $(element).attr('data-url');
  var org = $('#host_organization_id :selected').val();
  var loc = $('#host_location_id :selected').val();

  var data = {subnet_id: subnet_id, host_mac: interface_mac.val(), organization_id:org, location_id:loc }
  $.ajax({
    data: data,
    type:'post',
    url: url,
    dataType:'json',
    success:function (result) {
      interface_ip.val(result['ip']);
    },
    complete:function () {
      $(element).indicator_hide();
      interface_ip.attr('disabled', false);
    }
  });
}

function interface_type_selected(element) {

  var type = $(element).find('option:selected').text();
  var bmc_fields = $(element).parentsUntil('.fields').parent().find('#bmc_fields')
  if (type == 'BMC') {
    bmc_fields.find("input:disabled").prop('disabled',false);
    bmc_fields.removeClass("hide");
  } else {
    bmc_fields.find("input").prop('disabled',true);
    bmc_fields.addClass("hide");
  }

}
