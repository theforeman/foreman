$(document).on('ContentLoad', function(){onHostEditLoad()});
$(document).on('AddedClass', function(event, link){load_puppet_class_parameters(link)});

function update_nics(success_callback) {
  var data = $('form').serialize().replace('method=put', 'method=post');
  $('#network').html(spinner_placeholder(__('Loading interfaces information ...')));
  $('#network_tab a').removeClass('tab-error');

  var url = $('#network_tab').data('refresh-url');
  $.ajax({
    type:'post',
    url: url,
    data: data,
    complete: function(){},
    error: function(jqXHR, status, error){
      $('#network').html(Jed.sprintf(__("Error loading interfaces information: %s"), error));
      $('#network_tab a').addClass('tab-error');
    },
    success: function(result){
      $('#network').html(result);
      if ($('#network').find('.alert-danger').length > 0)
        $('#network_tab a').addClass('tab-error');
      update_interface_table();
      success_callback();
    }
  })
}

function computeResourceSelected(item){
  providerSpecificNICInfo = null;
  var compute = $(item).val();
  if (compute == '' && /compute_resource/.test($(item).attr('name'))) {
    //Bare metal compute resource
    $("#model_name").show();
    $('#compute_resource').empty();
    $('#vm_details').empty();
    $("#compute_resource_tab").hide();
    $("#compute_profile").hide();
    update_capabilities('build');
    update_nics(function() {
      interface_subnet_selected(primary_nic_form().find('select.interface_subnet'));
    });
  } else {
    //Real compute resource or any compute profile
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
      complete: function(){
        $(item).indicator_hide()
        update_nics(function() {
          interface_subnet_selected(primary_nic_form().find('select.interface_subnet'));
        });
      },
      error: function(jqXHR, status, error){
        $('#compute_resource').html(Jed.sprintf(__("Error loading virtual machine information: %s"), error));
        $('#compute_resource_tab a').addClass('tab-error');
      },
      success: function(result){
        $('#compute_resource').html(result).find('select:not(without_select2)').select2();
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

function submit_with_all_params(){
  var url = window.location.pathname.replace(/\/edit$|\/new|\/\d+.*\/nest$/,'');
  if (url.match('hostgroups')) {
    resource = 'hostgroup'
  } else {
    resource = 'host'
  }
  resources = resource + 's';
  capitalized_resource = resource[0].toUpperCase + resource.slice(1);
  if(/\/clone$/.test(window.location.pathname)){ url = foreman_url('/' + resources); }
  $('form input[type="submit"]').attr('disabled', true);
  stop_pooling = false;
  $("body").css("cursor", "progress");
  clear_errors();
  animate_progress();

  $.ajax({
    type:'POST',
    url: url,
    data: $('form').serialize(),
    success: function(response){
      $('#' + resource + '-progress').hide();
      $('#content').replaceWith($("#content", response));
      $(document.body).trigger('ContentLoad');
      if($("[data-history-url]").exists()){
          history.pushState({}, capitalized_resource + " show", $("[data-history-url]").data('history-url'));
      }
    },
    error: function(response){
      $('#content').html(response.responseText);
    },
    complete: function(){
      stop_pooling = true;
      $("body").css("cursor", "auto");
      $('form input[type="submit"]').attr('disabled', false);
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
    if (typeof url !== 'undefined') {
      $.get(url, function (response) {
        update_progress(response);
        animate_progress();
      })
    }
  }, 1600);
}

function update_progress(data){
  var task_list_size = $('p',data).length;
  if (task_list_size == 0 || stop_pooling == true) return;

  var done_tasks = $('.glyphicon-check',data).length;
  var failed_tasks = $('.glyphicon-remove',data).length;

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
  if (url.match('hostgroups')) {
    data = data + '&hostgroup_id=' + host_id
  } else {
    data = data + '&host_id=' + host_id
  }

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
      params.find('a[rel="popover"]').popover();
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
    } else if (host_changed == undefined) { // hostgroup changes parent
      update_form(element);
    } else { // edit host
      set_inherited_value(element);
      update_puppetclasses(element);
      reload_host_params();
    }
  } else { // a new host
    set_inherited_value(element);
    update_form(element);
  }
}

function set_inherited_value(hostgroup_elem) {
  var had_hostgroup = $(hostgroup_elem).data("had-hostgroup")

  if (had_hostgroup) {
    return;
  }

  var hostgroup_selected = hostgroup_elem.value != ""
  $("[name=is_overridden_btn]").each(function(i, btn) {
    var item = $(btn)
    var is_active = item.hasClass("active");
    var is_explicit = item.data('explicit');
    if (!is_explicit &&
        ((hostgroup_selected && !is_active) ||
        (!hostgroup_selected && is_active))) {
      disableButtonToggle(item, false);
    }
  })
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
    complete: function(){ $(element).indicator_hide(); },
    success: function(response) {
      $('form').replaceWith(response);
      multiSelectOnLoad();
      // to handle case if def process_taxonomy changed compute_resource_id to nil
      if( !$('#host_compute_resource_id').val() ) {
        $('#host_compute_resource_id').change();
      }
      update_capabilities($('#host_compute_resource_id').val() ? $('#capabilities').val() : 'build');

      $(document.body).trigger('ContentLoad');
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

function architecture_selected(element){
  var attrs   = attribute_hash(['architecture_id', 'organization_id', 'location_id']);
  var url = $(element).attr('data-url');
  $(element).indicator_show();
  $.ajax({
    data: attrs,
    type:'post',
    url: url,
    complete: function(){
      reloadOnAjaxComplete(element);
    },
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
    complete: function(){
      reloadOnAjaxComplete(element);
    },
    success: function(request) {
      $('#media_select').html(request);
      reload_host_params();
    }
  });
  update_provisioning_image();
}
function update_provisioning_image(){
  var compute_id = $('[name$="[compute_resource_id]"]').val();
  var arch_id = $('[name$="[architecture_id]"]').val();
  var os_id = $('[name$="[operatingsystem_id]"]').val();
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
  var param_value = param.find('[id^=value_]');
  var v = param_value.val();

  $('#parameters').find('.btn-success').click();
  var new_param = $('#parameters').find('.fields').last();
  new_param.find('[id$=_name]').val(n);
  new_param.find('[id$=_value]').val(v == param_value.data('hidden-value') ? '' : v);
  mark_params_override();
}

function override_class_param(item){
  var remove = $(item).data('tag') == 'remove';
  var row = $(item).parents('tr').toggleClass('overridden');
  var value = row.find('textarea');
  row.find('[type=checkbox]').prop('checked', false).toggle();
  row.find('input, textarea').prop('disabled', remove);
  row.find('.send_to_remove').prop('disabled', false);
  row.find('.destroy').val(remove);
  value.val(value.data('original-value'));
  $(item).hide().siblings().show();
}

function reload_host_params(){
  var host_id = $("form").data('id');
  var url = $('#params-tab').data('url');
  var data = $("[data-submit='progress_bar']").serialize().replace('method=put', 'method=post');
  if (url.match('hostgroups')) {
    var parent_id = $('#hostgroup_parent_id').val()
    data = data + '&hostgroup_id=' + host_id + '&hostgroup_parent_id=' + parent_id
  } else {
    data = data + '&host_id=' + host_id
  }
  load_with_placeholder('inherited_parameters', url, data)
}

function reload_puppetclass_params(){
  var host_id = $("form").data('id');
  var url2 = $('#params-tab').data('url2');
  var data = $("[data-submit='progress_bar']").serialize().replace('method=put', 'method=post');
  if (url2.match('hostgroups')) {
    data = data + '&hostgroup_id=' + host_id
  } else {
    data = data + '&host_id=' + host_id
  }
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
  update_interface_table();
  $("#host-conflicts-modal").modal({show: "true", backdrop: "static"});
   $('#host-conflicts-modal').click(function(){
     $('#host-conflicts-modal').modal('hide');
   });
  $('#image_selection').appendTo($('#image_provisioning'));
  $('#params-tab').on('shown', function(){mark_params_override()});
  if ($('#supports_update') && !$('#supports_update').data('supports-update')) disable_vm_form_fields();
}

$(document).on('submit',"[data-submit='progress_bar']", function() {
  // onContentLoad function clears any un-wanted parameters from being sent to the server by
  // binding 'click' function before this submit. see '$('form').on('click', 'input[type="submit"]', function()'
  submit_with_all_params();
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

$(document).on('click', '.suggest_new_ip', function (e) {
  clearError($(this).closest('fieldset').find('.interface_ip'));
  interface_subnet_selected($(this).closest('fieldset').find('select.interface_subnet'));
  e.preventDefault();
});

$(document).on('change', '.interface_subnet', function () {
  interface_subnet_selected(this);
});

$(document).on('change', '.interface_type', function () {
  interface_type_selected(this);
});

function interface_domain_selected(element) {
  // mark the selected value to preserve it for form hiding
  preserve_selected_options($(element));

  var domain_id = element.value;
  var subnet_options = $(element).closest('fieldset').find('[id$=_subnet_id]').empty();

  subnet_options.attr('disabled', true);

  $(element).indicator_show();

  var url = $(element).attr('data-url');

  var org = $('#host_organization_id :selected').val();
  var loc = $('#host_location_id :selected').val();

  $.ajax({
    data:{domain_id: domain_id, organization_id:org, location_id: loc, interface: true},
    type:'post',
    url:url,
    dataType:'json',
    success:function (result) {
      if (result.length > 1)
        subnet_options.append($("<option />").val(null).text(__('Please select')));

      $.each(result, function () {
        subnet_options.append($("<option />").val(this.subnet.id).text(this.subnet.to_label));
      });
      if (subnet_options.find('option').length > 0) {
        subnet_options.attr('disabled', false);
        subnet_options.change();
      }
      else {
        subnet_options.append($("<option />").text(__('No subnets')));
        subnet_options.attr('disabled', true);
      }
      reloadOnAjaxComplete(element);
      subnet_options.filter('select').select2({allowClear: true})
    }
  });
}

function interface_subnet_selected(element) {
  // mark the selected value to preserve it for form hiding
  preserve_selected_options($(element));

  var subnet_id = $(element).val();
  if (subnet_id == '') return;
  var interface_ip = $(element).closest('fieldset').find('input[id$=_ip]');

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
  var interface_mac = $(element).closest('fieldset').find('input[id$=_mac]');
  var url = $(element).attr('data-url');
  var org = $('#host_organization_id :selected').val();
  var loc = $('#host_location_id :selected').val();

  var taken_ips = $(active_interface_forms()).find('.interface_ip').map(function() {
    return $(this).val();
  }).get();
  taken_ips.push(interface_ip.val());

  var data = {
    subnet_id: subnet_id,
    host_mac: interface_mac.val(),
    organization_id: org,
    location_id: loc,
    taken_ips: taken_ips
  }
  $.ajax({
    data: data,
    type:'post',
    url: url,
    dataType:'json',
    success:function (result) {
      interface_ip.val(result['ip']);
      update_interface_table();
    },
    error: function(request, status, error) {
      setError(interface_ip, Jed.sprintf(__("Error generating IP: %s"), error));
    },
    complete:function () {
      $(element).indicator_hide();
      interface_ip.attr('disabled', false);
    }
  });
}

function interface_type_selected(element) {
  var fieldset = $(element).closest("fieldset");
  var data = fieldset.serializeArray();
  data.push({
    name: 'host[compute_resource_id]',
    value: $('#host_compute_resource_id').val()
  })

  request = $.ajax({
              data: data,
              type: 'GET',
              url: fieldset.attr('data-url'),
              dataType: 'script'
            });

  request.done(function() {
    password_caps_lock_hint();
    $("#interfaceModal").find('a[rel="popover-modal"]').popover();
    $('select:not(.without_select2)').select2({ allowClear: true });
  });
}

function disable_vm_form_fields() {
  $("#update_not_supported").show();
  $("[id^=host_compute_attributes]").each(function () {
    $(this).attr("disabled", "disabled");
  });
}

function selectedSubnetHasIPAM() {
  var subnet = $("#host_subnet_id")
  var subnet_id = subnet.val();
  var subnets =  subnet.data("subnets");
  if (subnet_id == '') return true;
  return subnets[subnet_id]['ipam'];
};

function setError(field, text) {
  var form_group = field.parents(".form-group").first();
  form_group.addClass("has-error");
  var help_block = form_group.children(".help-inline").first();
  var span = $( document.createElement('span') );
  span.addClass("error-message").html(text);
  help_block.prepend(span);
};

function clearError(field) {
  var form_group = field.parents(".form-group").first();
  form_group.removeClass("has-error");
  var error_block = form_group.children(".help-inline").children(".error-message");
  error_block.remove();
};
