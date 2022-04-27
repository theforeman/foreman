//= require parameter_override

$(document).on('ContentLoad', function() {
  onHostEditLoad();
});
$(document)
  .on('change', '.hostgroup-select', function(evt) {
    hostgroup_changed(evt.target);
  }).on('change', '.host-form-compute-resource-handle', function(evt) {
    computeResourceSelected(evt.target);
  }).on('change', '.host-taxonomy-select', function(evt) {
    update_form(evt.target);
  }).on('change', '.host-architecture-select', function(evt) {
    architecture_selected(evt.target);
  }).on('change', '.host-architecture-os-select', function(evt) {
    os_selected(evt.target);
  }).on('change', '.host-os-media-select', function(evt) {
    medium_selected(evt.target);
  });

function update_nics(success_callback) {
  var data = serializeForm().replace('method=patch', 'method=post');
  $('#network').html(
    spinner_placeholder(__('Loading interfaces information ...'))
  );
  $('#network_tab a').removeClass('tab-error');

  var url = $('#network_tab').data('refresh-url');
  $.ajax({
    type: 'post',
    url: url,
    data: data,
    complete: function() {},
    error: function(jqXHR, status, error) {
      $('#network').html(
        tfm.i18n.sprintf(__('Error loading interfaces information: %s'), error)
      );
      $('#network_tab a').addClass('tab-error');
    },
    success: function(result) {
      $('#network').html(result);
      if ($('#network').find('.alert-danger').length > 0)
        $('#network_tab a').addClass('tab-error');
      update_interface_table();
      success_callback();
    },
  });
}

var nic_update_handler = function() {
  update_nics(updatePrimarySubnetIPs);
};

function updatePrimarySubnetIPs() {
  interface_subnet_selected(
    primary_nic_form().find('select.interface_subnet'),
    'ip'
  );
  interface_subnet_selected(
    primary_nic_form().find('select.interface_subnet6'),
    'ip6'
  );
}

function computeResourceSelected(item) {
  providerSpecificNICInfo = null;
  var compute = $(item).val();
  if (compute == '' && /compute_resource/.test($(item).attr('name'))) {
    //Bare metal compute resource
    $('#model_name').show();
    $('#compute_resource').empty();
    $('#vm_details').empty();
    $('#compute_resource_tab').hide();
    $('#compute_profile').hide();
    update_capabilities($('#bare_metal_capabilities').val());
    nic_update_handler();
  } else {
    //Real compute resource or any compute profile
    $('#model_name').hide();
    $('#compute_resource_tab').show();
    $('#compute_profile').show();
    $('#vm_details').empty();
    var data = serializeForm().replace('method=patch', 'method=post');
    $('#compute_resource').html(
      spinner_placeholder(__('Loading virtual machine information ...'))
    );
    $('#compute_resource_tab a').removeClass('tab-error');
    tfm.tools.showSpinner();
    var url = $(item).attr('data-url');
    $.ajax({
      type: 'post',
      url: url,
      data: data,
      complete: function() {
        tfm.tools.hideSpinner();
        handle_nic_updates();
      },
      error: function(jqXHR, status, error) {
        $('#compute_resource').html(jqXHR.responseText);
        $('#compute_resource_tab a').addClass('tab-error');
      },
      success: function(result) {
        $('#compute_resource').html(result);
        activate_select2('#compute_resource');
        if ($('#compute_resource').find('.alert-danger').length > 0)
          $('#compute_resource_tab a').addClass('tab-error');
        update_capabilities($('#capabilities').val());
      },
    });
  }
}

function handle_nic_updates() {
  var modal_window = $('#interfaceModal');
  if (modal_window.is(':visible')) {
    modal_window.modal('hide').on('hidden.bs.modal', nic_update_handler);
  } else {
    nic_update_handler();
  }
}

function update_capabilities(capabilities) {
  capabilities = capabilities.split(' ');
  $('#image_provisioning').empty();
  $('#image_selection').appendTo($('#image_provisioning'));
  update_provisioning_image();
  $('#manage_network').empty();
  $('#subnet_selection').appendTo($('#manage_network'));

  $('input[id^=host_provision_method_]').attr('disabled', true);
  for (i = 0; i < capabilities.length; i++) {
    $('input[id^=host_provision_method_' + capabilities[i] + ']').attr(
      'disabled',
      false
    );
  }

  var build = capabilities.indexOf('build') > -1;
  if (build) {
    $('#manage_network_build').show();
    $('#host_provision_method_build').click();
    build_provision_method_selected();
  } else if (capabilities.length > 0) {
    $('#manage_network_build').hide();
    $('#host_provision_method_' + capabilities[0]).click();
    if (capabilities[0].toLowerCase() === 'image') {
      image_provision_method_selected();
    }
  }

  if (capabilities.length >= 2) {
    $('#provisioning_method').show();
  } else {
    $('#provisioning_method').hide();
  }
  multiSelectOnLoad();
}

var stop_pooling;

function submit_with_all_params() {
  $('form.hostresource-form input[type="submit"]').attr('disabled', true);
  stop_pooling = false;
  $('body').css('cursor', 'progress');
  clear_errors();
  animate_progress();

  $.ajax({
    type: 'POST',
    url: $('form').attr('action'),
    data: serializeForm(),
    success: function(response, _responseStatus, _jqXHR) {
      // workaround for redirecting to the new host details page
      if (!response.includes('id="main"')) {
        return tfm.nav.pushUrl(tfm.tools.foremanUrl('/new/hosts/' + construct_host_name()));
      }

      $('#host-progress').hide();
      $('#content').replaceWith($('#content', response));
      $(document.body).trigger('ContentLoad');
      if ($("[data-history-url]").exists()) {
        history.pushState({}, 'Host show', $("[data-history-url]").data('history-url'));
      }
    },
    error: function(response) {
      $('#content').html(response.responseText);
    },
    complete: function() {
      stop_pooling = true;
      $('body').css('cursor', 'auto');
      $('form input[type="submit"]').attr('disabled', false);
      if (window.location.pathname !== tfm.tools.foremanUrl('/hosts/new')) {
        // We got redirected to the show page, need to clear the title override
        tfm.store.dispatch('updateBreadcrumbTitle');
      }
    },
  });

  return false;
}

function clear_errors() {
  $('.error')
    .children()
    .children('.help-block')
    .remove();
  $('.error').removeClass('error');
  $('.tab-error').removeClass('tab-error');
  $('.alert-danger').remove();
}

function animate_progress() {
  if (stop_pooling == true) return;
  setTimeout(function() {
    var url = $('#host_progress_report_id').data('url');
    if (typeof url !== 'undefined') {
      $.get(url, function(response) {
        update_progress(response);
        animate_progress();
      });
    }
  }, 1600);
}

function update_progress(data) {
  var task_list_size = $('p', data).length;
  if (task_list_size == 0 || stop_pooling == true) return;

  var done_tasks = $('.glyphicon-check', data).length;
  var failed_tasks = $('.pficon-close', data).length;

  $('#host-progress').show();
  if (failed_tasks > 0) {
    $('.progress-bar').addClass('progress-bar-danger');
  } else {
    $('.progress-bar').removeClass('progress-bar-danger');
  }
  $('.progress-bar').width((done_tasks / task_list_size) * 100 + '%');
  $('#tasks_progress').replaceWith(data);
}

function hostgroup_changed(element) {
  var host_id = $('form').data('id');
  var host_changed = $('form').data('type-changed');
  if (host_id) {
    handleHostgroupChangeEdit(element, host_id, host_changed);
  } else {
    // a new host
    handleHostgroupChangedNew(element);
  }
}

function handleHostgroupChangeEdit(element, host_id, host_changed) {
  if (host_changed) {
    update_form(element, { data: '&host[id]=' + host_id });
  } else if (host_changed == undefined) {
    // hostgroup changes parent
    update_form(element);
  } else {
    // edit host
    set_inherited_value(element);
    reload_host_params();
  }
}

function handleHostgroupChangedNew(element) {
  reset_explicit_values(element);
  set_inherited_value(element);
  // call for form update only if there is a hostgroup selected
  if ($('#host_hostgroup_id').val() != '') {
    $('#host_compute_resource_id').prop('disabled', true);
    return update_form(element);
  }
}

function reset_explicit_values(element) {
  $('[name=is_overridden_btn]').each(function(i, btn) {
    var item = $(btn);
    var formControl = item.closest('.input-group').find('.form-control');
    formControl.attr('disabled', true);
  });
}

function set_inherited_value(hostgroup_elem) {
  var had_hostgroup = $(hostgroup_elem).data('had-hostgroup');

  if (had_hostgroup) {
    return;
  }

  var hostgroup_selected = hostgroup_elem.value != '';
  $('[name=is_overridden_btn]').each(function(i, btn) {
    var item = $(btn);
    var is_active = item.hasClass('active');
    var is_explicit = item.data('explicit');
    if (
      !is_explicit &&
      ((hostgroup_selected && !is_active) || (!hostgroup_selected && is_active))
    ) {
      disableButtonToggle(item, false);
    }
  });
}

function update_form(element, options) {
  options = options || {};
  var url = $(element).data('url');
  var data = serializeForm().replace('method=patch', 'method=post');
  if (options.data) data = data + options.data;
  tfm.tools.showSpinner();
  return $.ajax({
    type: 'post',
    url: url,
    data: data,
    complete: function() {
      tfm.tools.hideSpinner();
    },
    success: function(response) {
      $('form.hostresource-form').replaceWith(response);
      multiSelectOnLoad();
      var host_compute_resource_id = $('#host_compute_resource_id');
      if (host_compute_resource_id.exists()) {
        // to handle case if def process_taxonomy changed compute_resource_id to nil
        if (!host_compute_resource_id.val()) {
          host_compute_resource_id.change();
        } else {
          // in case the compute resource was selected, we still want to check for
          // free ip if applicable
          updatePrimarySubnetIPs();
        }
        update_capabilities(
          host_compute_resource_id.val()
            ? $('#capabilities').val()
            : $('#bare_metal_capabilities').val()
        );
      }

      $(document.body).trigger('ContentLoad');
    },
  });
}

//Serializes only those input elements from form that are set explicitly
function serializeForm() {
  return $('form.hostresource-form input,select,textarea')
    .not('.form_template *')
    .serialize();
}

function subnet_contains(network, cidr, ip) {
  if (!ip || 0 === ip.length || !ipaddr.isValid(ip)) {
    return;
  }

  var addr = ipaddr.parse(ip);
  var range = ipaddr.parse(network);

  return addr.match(range, cidr);
}

function architecture_selected(element) {
  var url = $(element).attr('data-url');
  var type = $(element).attr('data-type');
  var attrs = {};
  attrs[type] = attribute_hash(tfm.hosts.getAttributesToPost('architecture'));
  tfm.tools.showSpinner();
  $.ajax({
    data: attrs,
    type: 'post',
    url: url,
    complete: function() {
      reloadOnAjaxComplete(element);
    },
    success: function(request) {
      $('#os_select').html(request);
    },
  });
}

function os_selected(element) {
  var url = $(element).attr('data-url');
  var type = $(element).attr('data-type');
  var attrs = {};
  attrs[type] = attribute_hash(tfm.hosts.getAttributesToPost('os'));
  tfm.tools.showSpinner();
  $.ajax({
    data: attrs,
    type: 'post',
    url: url,
    complete: function() {
      reloadOnAjaxComplete(element);
    },
    success: function(request) {
      $('#media_select').html(request);
      reload_host_params();
    },
  });
  update_provisioning_image();
}
function update_provisioning_image() {
  var compute_id = $('[name$="[compute_resource_id]"]').val();
  var arch_id = $('[name$="[architecture_id]"]').val();
  var os_id = $('[name$="[operatingsystem_id]"]').val();
  if (
    compute_id == undefined ||
    compute_id == '' ||
    arch_id == '' ||
    os_id == ''
  )
    return;
  var image_options = $('#image_selection select').empty();
  $.ajax({
    data: { operatingsystem_id: os_id, architecture_id: arch_id },
    type: 'get',
    url: tfm.tools.foremanUrl('/compute_resources/' + compute_id + '/images'),
    dataType: 'json',
    success: function(result) {
      $.each(result, function() {
        image_options.append(
          $('<option />')
            .val(this.uuid)
            .text(this.name)
        );
      });
      if (image_options.find('option').length > 0) {
        if ($('#host_provision_method_image')[0].checked) {
          if ($('#provider').val() == 'Libvirt') {
            tfm.computeResource.libvirt.imageSelected(image_options);
          } else if ($('#provider').val() == 'Ovirt') {
            var template_select = $('#host_compute_attributes_template');
            if (template_select.length > 0) {
              template_select.val(image_options.val());
              tfm.computeResource.ovirt.templateSelected(image_options);
            }
          }
        }
      }
    },
  });
}

function medium_selected(element) {
  var url = $(element).attr('data-url');
  var type = $(element).attr('data-type');
  var attrs = {};
  attrs[type] = attribute_hash(tfm.hosts.getAttributesToPost('medium'));
  attrs[type]['use_image'] = $('*[id*=use_image]').attr('checked') == 'checked';
  $.ajax({
    data: attrs,
    type: 'post',
    url: url,
    success: function(request) {
      $('#image_details').html(request);
    },
  });
}

function use_image_selected(element) {
  var url = $(element).attr('data-url');
  var type = $(element).attr('data-type');
  var attrs = {};
  attrs[type] = attribute_hash(tfm.hosts.getAttributesToPost('image'));
  attrs[type]['use_image'] = $(element).attr('checked') == 'checked';
  $.ajax({
    data: attrs,
    type: 'post',
    url: url,
    success: function(response) {
      var field = $('*[id*=image_file]');
      if (attrs[type]['use_image']) {
        if (field.val() == '') field.val(response['image_file']);
      } else field.val('');

      field.attr('disabled', !attrs[type]['use_image']);
    },
  });
}

function reload_host_params() {
  var host_id = $('form.hostresource-form').data('id');
  var url = $('#params-tab').data('url');
  var data = serializeForm().replace('method=patch', 'method=post');
  if (url.length > 0) {
    data = data + '&host_id=' + host_id;
    load_with_placeholder('inherited_parameters', url, data);
  }
}

function load_with_placeholder(target, url, data) {
  if (url == undefined) return;
  var placeholder = $(
    '<tr id="' +
      target +
      '_loading" >' +
      '<td colspan="4">' +
      spinner_placeholder(__('Loading parameters...')) +
      '</td></tr>'
  );
  $('#' + target + ' tbody').replaceWith(placeholder);
  $.ajax({
    type: 'post',
    url: url,
    data: data,
    success: function(result, textstatus, xhr) {
      placeholder.closest('#' + target).replaceWith($(result));
      mark_params_override();
    },
  });
}

function onHostEditLoad() {
  update_interface_table();

  $('#host-conflicts-modal').modal({ show: 'true', backdrop: 'static' });
  $('#host-conflicts-modal').click(function() {
    $('#host-conflicts-modal').modal('hide');
  });
  $('#image_selection').appendTo($('#image_provisioning'));
  var compute = $('#host_compute_resource_id');
  if (compute.val() == '' && compute.attr('disabled') == 'disabled') {
    update_capabilities($('#bare_metal_capabilities').val());
  }
  $('#params-tab').on('shown', function() {
    mark_params_override();
  });
  if ($('#supports_update') && !$('#supports_update').data('supports-update'))
    disable_vm_form_fields();
  pxeLoaderCompatibilityCheck();
}

$(document).on('submit', "[data-submit='progress_bar']", function() {
  // onContentLoad function clears any un-wanted parameters from being sent to the server by
  // binding 'click' function before this submit. see '$('form').on('click', 'input[type="submit"]', function()'
  submit_with_all_params();
  return false;
});

function build_provision_method_selected() {
  $('div[id*=_provisioning]').hide();
  $('#network_provisioning').show();
  $('#image_selection select').attr('disabled', true);
  if ($('#provider').val() == 'Ovirt')
    $('#host_compute_attributes_template').select2('readonly',false);
}
$(document).on(
  'change',
  '#host_provision_method_build',
  build_provision_method_selected
);

function image_provision_method_selected() {
  $('div[id*=_provisioning]').hide();
  $('#image_provisioning').show();
  $('#network_selection select').attr('disabled', true);
  var image_options = $('#image_selection select');
  image_options.attr('disabled', false);
  if ($('#provider').val() == 'Libvirt') {
    tfm.computeResource.libvirt.imageSelected(image_options);
  } else if ($('#provider').val() == 'Ovirt') {
    var template_options = $('#host_compute_attributes_template');
    if (template_options.length > 0) {
      template_options.select2('readonly',true);
      template_options.val(image_options.val());
      tfm.computeResource.ovirt.templateSelected(image_options);
    }
  }
}
$(document).on(
  'change',
  '#host_provision_method_image',
  image_provision_method_selected
);

$(document).on('change', '.interface_domain', function() {
    interface_domain_selected(this);
    clearIpField(this, '.interface_ip');
    clearIpField(this, '.interface_ip6');
    reload_host_params();
});

function clearIpField(parent, childclass) {
  var ip_field = $(parent)
    .closest('fieldset')
    .find(childclass);
  clearError(ip_field);
  ip_field.val('');
}

function suggestNewClick(element, e, suffix) {
  suffix = suffix || '';
  clearIpField(element, '.interface_ip' + suffix);
  interface_subnet_selected(
    $(element)
      .closest('fieldset')
      .find('select.interface_subnet' + suffix),
    'ip' + suffix,
    true
  );
  e.preventDefault();
}

$(document).on('click', '.suggest_new_ip', function(e) {
  suggestNewClick(this, e);
});

$(document).on('click', '.suggest_new_ip6', function(e) {
  suggestNewClick(this, e, '6');
});

$(document).on('change', '.interface_subnet', function() {
  interface_subnet_selected(this, 'ip');
});

$(document).on('change', '.interface_subnet6', function() {
  interface_subnet_selected(this, 'ip6');
});

$(document).on('change', '.interface_mac', function() {
  var subnet_select = $(this)
    .closest('fieldset')
    .find('select.interface_subnet');
  var subnet6_select = $(this)
    .closest('fieldset')
    .find('select.interface_subnet6');
  clearIpField(subnet_select, '.interface_ip');
  clearIpField(subnet6_select, '.interface_ip6');
  interface_subnet_selected(subnet_select, 'ip');
  interface_subnet_selected(subnet6_select, 'ip6');
});

$(document).on('change', '.interface_type', function() {
  interface_type_selected(this);
});

function interface_subnet_activate_if_not_empty(element) {
  if (element.find('option').length > 0) {
    element.prepend(
      $('<option />')
        .val(null)
        .text(null)
        .prop('selected', true)
    );
    element.attr('disabled', false);
    element.change();
  } else {
    element.append($('<option />').text(__('No subnets')));
    element.attr('disabled', true);
  }
}

function toggle_suggest_new_link(element, ip_field) {
  var suggest_new_link = $(element)
    .closest('fieldset')
    .find('.suggest_new_' + ip_field);
  var subnet_supports_suggest_new = $(element)
    .find(':selected')
    .attr('data-suggest_new');
  if (subnet_supports_suggest_new === 'true') {
    suggest_new_link.fadeIn();
  } else {
    suggest_new_link.fadeOut();
  }
}

function interface_domain_selected_subnet_handler(field, suffix) {
  interface_subnet_activate_if_not_empty(field);
  toggle_suggest_new_link(field, suffix);
  activate_select2(field);
}

function interface_domain_selected(element) {
  // mark the selected value to preserve it for form hiding
  preserve_selected_options($(element));

  var domain_id = element.value;
  var subnet_options = $(element)
    .closest('fieldset')
    .find('[id$=_subnet_id]')
    .empty();
  var subnet6_options = $(element)
    .closest('fieldset')
    .find('[id$=_subnet6_id]')
    .empty();

  subnet_options.attr('disabled', true);
  subnet6_options.attr('disabled', true);

  tfm.tools.showSpinner();

  var url = $(element).attr('data-url');

  var org = $('#host_organization_id :selected').val();
  var loc = $('#host_location_id :selected').val();

  $.ajax({
    data: {
      domain_id: domain_id,
      organization_id: org,
      location_id: loc,
      interface: true,
    },
    type: 'post',
    url: url,
    dataType: 'json',
    success: function(result) {
      $.each(result, function() {
        select = null;
        if (this.type === 'Subnet::Ipv4') {
          select = subnet_options;
        } else if (this.type === 'Subnet::Ipv6') {
          select = subnet6_options;
        }
        if (select) {
          select.append(
            $('<option />')
              .val(this.id)
              .attr('data-suggest_new', this.unused_ip.suggest_new)
              .attr('data-vlan_id', this.vlanid)
              .text(this.to_label)
          );
        }
      });
      interface_domain_selected_subnet_handler(subnet_options, 'ip');
      interface_domain_selected_subnet_handler(subnet6_options, 'ip6');
      reloadOnAjaxComplete(element);
    },
  });
}

function interface_subnet_selected(element, ip_field, skip_mac) {
  // mark the selected value to preserve it for form hiding
  preserve_selected_options($(element));

  if ($(element).attr('disabled')) return;
  var subnet_id = $(element).val();
  if (subnet_id == '') return;
  var interface_ip = $(element)
    .closest('fieldset')
    .find('input[id$=_' + ip_field + ']');

  toggle_suggest_new_link(element, ip_field);

  selectRelatedNetwork(element);

  interface_ip.attr('disabled', true);
  tfm.tools.showSpinner();

  // We do not query the proxy if the ip field is filled in and contains an
  // IP that is in the selected subnet
  var drop_text = $(element)
    .children(':selected')
    .text();
  // extracts network / cidr / ip
  if (drop_text.length != 0 && drop_text.search(/^.+ \([0-9\.\/]+\)/) != -1) {
    var details = drop_text
      .replace(/^.+\(/, '')
      .replace(')', '')
      .split('/');
    var network = details[0];
    var cidr = details[1];

    if (subnet_contains(network, cidr, interface_ip.val())) {
      interface_ip.attr('disabled', false);
      tfm.tools.hideSpinner();
      return;
    }
  }
  var interface_mac = $(element)
    .closest('fieldset')
    .find('input[id$=_mac]');
  var url = $(element).attr('data-url');
  var org = $('#host_organization_id :selected').val();
  var loc = $('#host_location_id :selected').val();

  var taken_ips = $(active_interface_forms())
    .find('.interface_' + ip_field)
    .map(function() {
      return $(this).val();
    })
    .get();
  taken_ips.push(interface_ip.val());

  var data = {
    subnet_id: subnet_id,
    host_mac: skip_mac ? '' : interface_mac.val(),
    organization_id: org,
    location_id: loc,
    taken_ips: taken_ips,
  };
  $.ajax({
    data: data,
    type: 'post',
    url: url,
    dataType: 'json',
    success: function(result) {
      clearError(interface_ip);
      interface_ip.val(result['ip']);
      update_interface_table();
      clearError(interface_mac);
      if ('errors' in result) {
        if ('mac' in result['errors']) {
          setError(interface_mac, result['errors']['mac']);
        }
        if ('subnet' in result['errors']) {
          setError(interface_ip, result['errors']['subnet']);
        }
      }
    },
    error: function(request, status, error) {
      setError(
        interface_ip,
        tfm.i18n.sprintf(__('Error generating IP: %s'), error)
      );
    },
    complete: function() {
      tfm.tools.hideSpinner();
      interface_ip.attr('disabled', false);
    },
  });
}

function selectRelatedNetwork(subnetElement) {
  var subnet_select = $(subnetElement);
  var vlanId = subnet_select.find(':selected').attr('data-vlan_id');
  var network_select = subnet_select
    .closest('fieldset')
    .find('.vmware_network,.ovirt_network');
  var isVisible = subnet_select.closest('#interfaceModal').length > 0;
  var isPreSelected = network_select.find('option[selected]').length > 0;

  if ((!isVisible && isPreSelected) || !vlanId || network_select.length == 0) {
    return;
  }

  var selected = null;
  // prefer a match of the vlanid bounded by non digits
  // this prevent vlanId=1 from matching "vlan100"
  var vlanidregex = new RegExp("(^|\\D)" + vlanId + "($|\\D)")

  network_select.find('option').each(function(index, option) {
    if (
      selected === null &&
      vlanidregex.test($(option).text())
    ) {
      selected = option.value;
    }
  });
  if (selected === null) {
    network_select.find('option').each(function(index, option) {
      if (
        selected === null &&
        $(option)
          .text()
          .indexOf(vlanId) !== -1
      ) {
        selected = option.value;
      }
    });
  }

  if (selected !== null) {
    network_select.val(selected).trigger('change');
    preserve_selected_options(network_select);
    update_interface_table();
  }
}

function interface_type_selected(element) {
  var fieldset = $(element).closest('fieldset');
  var data = fieldset.serializeArray();
  data.push({
    name: 'host[compute_resource_id]',
    value: $('#host_compute_resource_id').val(),
  });

  request = $.ajax({
    data: data,
    type: 'GET',
    url: fieldset.attr('data-url'),
    dataType: 'script',
  });

  request.done(function() {
    password_caps_lock_hint();
    $('#interfaceModal')
      .find('a[rel="popover-modal"]')
      .popover();
    activate_select2('#interfaceModal');
  });
}

function disable_vm_form_fields() {
  $('#update_not_supported').show();
  $('[id^=host_compute_attributes]').each(function() {
    $(this).attr('disabled', 'disabled');
  });
  $('[id^=host_interfaces_attributes]')
    .filter(function() {
      return this.id.match(
        /^host_interfaces_attributes_[0-9]+_compute_attributes_.*/
      );
    })
    .each(function() {
      $(this).attr('disabled', 'disabled');
    });
}

function selectedSubnetHasIPAM() {
  var subnet = $('#host_subnet_id');
  var subnet_id = subnet.val();
  var subnets = subnet.data('subnets');
  if (subnet_id == '') return true;
  return subnets[subnet_id]['ipam'];
}

function randomizeName() {
  $.ajax({
    type: 'GET',
    url: '/hosts/random_name',
    success: function(response, status, xhr) {
      var element = $('#host_name');
      element.val(response.name);
      element.focus();
      element.select();
    },
  });
}

function pxeLoaderCompatibilityCheck() {
  var pxeLoader = $('#host_pxe_loader').val();
  var osTitle = $('#host_operatingsystem_id option:selected').text();
  var compatible = tfm.hosts.checkPXELoaderCompatibility(osTitle, pxeLoader);
  if (compatible === false) {
    $('#host_pxe_loader')
      .closest('.form-group')
      .addClass('has-warning');
    $('#host_pxe_loader')
      .closest('.form-group')
      .find('.help-inline')
      .html(
        '<span class="error-message">' +
          __(
            'Warning: This combination of loader and OS might not be able to boot.'
          ) +
          ' ' +
          __('Manual configuration is needed.') +
          '</span>'
      );
  } else {
    $('#host_pxe_loader')
      .closest('.form-group')
      .removeClass('has-warning');
    $('#host_pxe_loader')
      .closest('.form-group')
      .find('.help-inline')
      .html('');
  }
}

$(document).on('change', '#host_pxe_loader', pxeLoaderCompatibilityCheck);
