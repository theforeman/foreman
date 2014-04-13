$(document).on('ContentLoad', function(){onHostEditLoad()});
$(document).on('AddedClass', function(event, link){load_puppet_class_parameters(link)});

function computeResourceSelected(item){
  var compute = $(item).val();
  if(compute=='') { //Bare Metal
    $('#mac_address').show();
    $("#model_name").show();
    $('#compute_resource').empty();
    $('#vm_details').empty();
    $("#compute_resource_tab").hide();
    $("#compute_profile").hide();
    update_capabilities('build');
  }
  else
  {
    $('#mac_address').hide();
    $("#model_name").hide();
    $("#compute_resource_tab").show();
    $("#compute_profile").show();
    $('#vm_details').empty();
    var data = $('form').serialize().replace('method=put', 'method=post');
    $('#compute_resource').html(spinner_placeholder(__('Loading virtual machine information ...')));
    $('#compute_resource_tab a').removeClass('tab-error');
    $(item).indicator_show();
    var url = $(item).attr('data-url');
    $.ajax({
      type:'post',
      url: url,
      data: data,
      complete: function(){$(item).indicator_hide()},
      error: function(jqXHR, status, error){
        $('#compute_resource').html(Jed.sprintf(__("Error loading virtual machine information: %s"), error));
        $('#compute_resource_tab a').addClass('tab-error');
      },
      success: function(result){
        $('#compute_resource').html(result);
        if ($('#compute_resource').find('.alert-danger').length > 0) $('#compute_resource_tab a').addClass('tab-error');
        update_capabilities($('#capabilities').val());
      }
    })
  }
}

function update_capabilities(capabilities){
  $('#image_provisioning').empty();
  $('#image_selection').appendTo($('#image_provisioning'));
  update_provisioning_image();
  $('#manage_network').empty();
  $('#subnet_selection').appendTo($('#manage_network'));

  var build = (/build/i.test(capabilities));
  var image = (/image/i.test(capabilities));
  if (build){
    $('#manage_network_build').show();
    $('#host_provision_method_build').click();
    build_provision_method_selected();
  } else {
    $('#manage_network_build').hide();
    $('#host_provision_method_image').click();
    image_provision_method_selected();
  }
  if(build && image){
    $('#provisioning_method').show();
  }else{
    $('#provisioning_method').hide();
  }
  multiSelectOnLoad();
}

var stop_pooling;

function submit_host(){
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
    data: $('form').serialize(),
    success: function(response){
      if(response.redirect){
        window.location.replace(response.redirect);
      }
      else{
        $("#host-progress").hide();
        $('#content').replaceWith($("#content", response));
        $(document.body).trigger('ContentLoad');
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
  $('.error').children().children('.help-block').remove();
  $('.error').removeClass('error');
  $('.tab-error').removeClass('tab-error');
  $('.alert-danger').remove();
}

function animate_progress(){
  if (stop_pooling == true) return;
  setTimeout(function() {
    var url = $('#host_progress_report_id').data('url');
    $.get(url, function (response){
       update_progress(response);
       animate_progress();
    })
  }, 1600);
}

function update_progress(data){
  var task_list_size = $('p',data).size();
  if (task_list_size == 0 || stop_pooling == true) return;

  var done_tasks = $('.glyphicon-check',data).size();
  var failed_tasks = $('.glyphicon-remove',data).size();

  $("#host-progress").show();
  if(failed_tasks > 0) {
    $('.progress-bar').addClass('progress-bar-danger');
  }else{
    $('.progress-bar').removeClass('progress-bar-danger');
  }
  $('.progress-bar').width(done_tasks/task_list_size * 100 + '%')
  $('#tasks_progress').replaceWith(data);
}

function load_puppet_class_parameters(item) {
  var id = $(item).attr('data-class-id');
  // host_id could be either host.id OR hostgroup.id depending on which form
  var host_id = $("form").data('id')
  if ($('#puppetclass_' + id + '_params_loading').length > 0) return; // already loading
  if ($('[id^="#puppetclass_' + id + '_params\\["]').length > 0) return; // already loaded
  var url = $(item).attr('data-url');
  var data = $("form").serialize().replace('method=put', 'method=post');
  data = data + '&host_id=' + host_id

  if (url == undefined) return; // no parameters
  var placeholder = $('<tr id="puppetclass_'+id+'_params_loading">'+
      '<td colspan="5">' + spinner_placeholder(__('Loading parameters...')) + '</td></tr>');
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
  var host_id = $("form").data('id');
  var host_changed = $("form").data('type-changed');
  if (host_id) {
    if (host_changed ){
      update_form(element,{data:"&host[id]="+host_id});
    } else { // edit host
      update_puppetclasses(element);
      reload_host_params();
    }
  } else { // a new host
    update_form(element);
  }
}

function organization_changed(element) {
  update_form(element);
}

function location_changed(element) {
  update_form(element);
}


function update_form(element, options) {
  options = options || {};
  var url = $(element).data('url');
  var data = $('form').serialize().replace('method=put', 'method=post');
  if (options.data) data = data+options.data;
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
      update_capabilities($('#host_compute_resource_id').val() ? $('#capabilities').val() : 'build');
      $(document.body).trigger('ContentLoad');
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
        if (image_options.find('option').length > 0) {
          if ($('#host_provision_method_image')[0].checked) {
            if ($('#provider').val() == 'Libvirt') {
              libvirt_image_selected(image_options);
            } else if ($('#provider').val() == 'Ovirt') {
              var template_select = $('#host_compute_attributes_template');
              if (template_select.length > 0) {
                template_select.val(image_options.val());
                ovirt_templateSelected(image_options);
              }
            }
          }
        }
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
  var new_param = param.closest('.tab-pane').find('[id*=host_host_parameters]:visible').last().parent().parent();
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
  var new_param = param.closest('.tab-pane').find('[id*=_lookup_values]:visible').last().parents('.form-group');
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
            '<td colspan="4">'+ spinner_placeholder(__('Loading parameters...')) + '</td></tr>');
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

function onHostEditLoad(){
  $("#host-conflicts-modal").modal({show: "true", backdrop: "static"});
   $('#host-conflicts-modal').click(function(){
     $('#host-conflicts-modal').modal('hide');
   });
  $('#image_selection').appendTo($('#image_provisioning'));
  $('#params-tab').on('shown', function(){mark_params_override()});
  if ($('#supports_update') && !$('#supports_update').data('supports-update')) disable_vm_form_fields();
}

$(document).on('submit',"[data-submit='progress_bar']", function() {
  submit_host();
  return false;
});

function build_provision_method_selected() {
  $('#network_provisioning').show();
  $('#image_provisioning').hide();
  $('#image_selection select').attr('disabled', true);
  if ($('#provider').val() == 'Ovirt')
    $('#host_compute_attributes_template').attr('disabled', false);
}
$(document).on('change', '#host_provision_method_build', build_provision_method_selected);

function image_provision_method_selected() {
  $('#network_provisioning').hide();
  $('#image_provisioning').show();
  $('#network_selection select').attr('disabled', true);
  var image_options = $('#image_selection select');
  image_options.attr('disabled', false);
  if ($('#provider').val() == 'Libvirt') {
    libvirt_image_selected(image_options);
  } else if ($('#provider').val() == 'Ovirt') {
    var template_options = $('#host_compute_attributes_template');
    if (template_options.length > 0) {
      template_options.attr('disabled', true);
      template_options.val(image_options.val());
      ovirt_templateSelected(image_options);
    }
  }
}
$(document).on('change', '#host_provision_method_image', image_provision_method_selected);

$(document).on('change', '.interface_domain', function () {
  interface_domain_selected(this);
});

$(document).on('click', '#suggest_new_ip', function (e) {
  $('#host_ip').val('')
  interface_subnet_selected($('#host_subnet_id'));
  e.preventDefault();
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
    subnet_options.append($("<option />").val(null).text(__('No subnets')));
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
        subnet_options.append($("<option />").val(null).text(__('Please select')));

      $.each(result, function () {
        subnet_options.append($("<option />").val(this.subnet.id).text(this.subnet.name + ' (' + this.subnet.to_label + ')'));
      });
      if (subnet_options.find('option').length > 0) {
        subnet_options.attr('disabled', false);
        subnet_options.change();
      }
      else {
        subnet_options.append($("<option />").text(__('No subnets')));
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

function disable_vm_form_fields() {
  $("#update_not_supported").show();
  $("[id^=host_compute_attributes]").each(function () {
    $(this).attr("disabled", "disabled");
  });
  $("a.disable-unsupported").remove();
}
