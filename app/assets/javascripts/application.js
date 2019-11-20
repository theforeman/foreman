//= require jquery-ui/widgets/spinner
//= require bootstrap
//= require patternfly
//= require vendor
//= require jquery.extentions
//= require jquery.multi-select
//= require settings
//= require hidden_values
//= require select_on_click
//= require lookup_keys
//= require editable/bootstrap-editable
//= require editable/rails

$(function() {
  $(document).trigger('ContentLoad');
});

// Prevents all links with the disabled attribute set to "disabled"
// from being clicked.
var handleDisabledClick = function(event, element){
  var disabled = element.disabled || $(element).attr('disabled') === 'disabled';
  if (disabled) event.preventDefault();
  return !disabled;
}

$(document).on('click', 'a[disabled="disabled"]', function(event) {
  return handleDisabledClick(event, this);
});

function onContentLoad() {
  tfm.store.observeStore('layout', tfm.nav.showContent);

  if ($('input[focus_on_load=true]').length > 0) {
    $('input[focus_on_load]')
      .first()
      .focus();
  }

  // highlight tabs with errors
  var errorFields = $('.tab-content .has-error');
  errorFields.parents('.tab-pane').each(function() {
    $('a[href="#' + this.id + '"]').addClass('tab-error');
  });
  $('.tab-error')
    .first()
    .click();
  $('.nav-pills .tab-error')
    .first()
    .click();
  errorFields
    .first()
    .find('.form-control')
    .focus();

  $('a[rel="popover"]').popover();
  tfm.tools.activateTooltips();
  tfm.tools.activateDatatables();

  $('a[disabled="disabled"]').click(function(event) {
    return handleDisabledClick(event, this);
  });

  // allow opening new window for selected links
  $('a[rel="external"]').attr('target', '_blank');

  $('*[data-ajax-url]').each(function() {
    var url = $(this).data('ajax-url');
    $(this).removeAttr('data-ajax-url');
    $(this).load(url, function(response, status, xhr) {
      if (status == 'error') {
        if (!response.length) {
          response =
            __('Failed to fetch: ') + xhr.status + ' ' + xhr.statusText;
        }
        $(this).html(response);
      }
      if ($(this).data('on-complete')) {
        _.get(window, $(this).data('on-complete')).call(null, this, status);
      }
      tfm.tools.activateTooltips(this);
    });
  });

  multiSelectOnLoad();

  // Removes the value from fake password field.
  $('#fakepassword').val('');
  $('form').on('click', 'input[type="submit"]', function() {
    $('#fakepassword').remove();
  });

  password_caps_lock_hint();

  tfm.i18n.intl.ready.then(function() {
    var tz = jstz.determine();
    $.cookie('timezone', tz.name(), {
      path: '/',
      secure: location.protocol === 'https:',
    });
  });

  $('.full-value').SelectOnClick();
  activate_select2(':root');

  $('input.remove_form_templates')
    .closest('form')
    .submit(function(event) {
      $(this)
        .find('.form_template')
        .remove();
    });
}

function preserve_selected_options(elem) {
  // mark the selected values to preserve them for form hiding
  elem.find('option:not(:selected)').removeAttr('selected');
  elem.find('option:selected').attr('selected', 'selected');
}

function password_caps_lock_hint() {
  $('[type=password]').keypress(function(e) {
    var $addon = $(this)
        .parent()
        .children('.input-addon'),
      key = String.fromCharCode(e.which);

    if (check_caps_lock(key, e)) {
      if (!$addon.is(':visible')) $addon.show();
    } else if ($addon.is(':visible')) {
      $addon.hide();
    }
  });
}

//Tests if letter is upper case and the shift key is NOT pressed.
function check_caps_lock(key, e) {
  return key.toUpperCase() === key && key.toLowerCase() !== key && !e.shiftKey;
}

function remove_fields(link) {
  $(link)
    .prev('input[type=hidden]')
    .val('1');
  var $field_row = $(link).closest('.fields');
  $field_row.next('tr.error-msg-block').hide();
  $field_row.hide();
  mark_params_override();
}

function mark_params_override() {
  $('#inherited_parameters .override-param').removeClass('override-param');
  $('#parameters')
    .find('[id$=_name]:visible')
    .each(function() {
      var param_name = $(this);
      $('#inherited_parameters')
        .find('[id^=name_]')
        .each(function() {
          if (param_name.val() == $(this).text()) {
            $(this)
              .closest('tr')
              .addClass('override-param');
          }
        });
    });
  $('#params-tab').removeClass('tab-error');
  if ($('#params').find('.form-group.error').length > 0)
    $('#params-tab').addClass('tab-error');
  $('a[rel="popover"]').popover();
}

function add_fields(target, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp('new_' + association, 'g');
  $(target).append(content.replace(regexp, new_id));
}

$(document).ready(function() {
  $('#check_all_roles').click(function(e) {
    e.preventDefault();
    $('.role_checkbox').prop('checked', true);
  });

  $('#uncheck_all_roles').click(function(e) {
    e.preventDefault();
    $('.role_checkbox').prop('checked', false);
  });
});

function toggleCheckboxesBySelector(selector) {
  boxes = $(selector);
  var all_checked = true;
  for (i = 0; i < boxes.length; i++) {
    if (!boxes[i].checked) {
      all_checked = false;
    }
  }
  for (i = 0; i < boxes.length; i++) {
    boxes[i].checked = !all_checked;
  }
}

function toggleRowGroup(el) {
  var tr = $(el).closest('tr');
  var n = tr.next();
  tr.toggleClass('open');
  while (n.length > 0 && !n.hasClass('group')) {
    n.toggle();
    n = n.next();
  }
}

function template_info(div, url) {
  // Ignore method as PUT redirects to host page if used on update
  form = $("form :input[name!='_method']").serialize();
  build = $('input:radio[name$="[provision_method]"]:checked').val();
  $(div).html(spinner_placeholder());
  // Use a post to avoid request URI too large issues with big forms
  $.ajax({
    type: 'POST',
    url: url + (url.indexOf('?') == -1 ? '?' : '&') + 'provisioning=' + build,
    data: form,
    success: function(response, status, xhr) {
      $(div).html(response);
      activate_select2(div);
    },
    error: function(jqXHR, textStatus, errorThrown) {
      $(div).html(
        '<div class="alert alert-warning alert-dismissable">' +
          tfm.tools.iconText('warning-triangle-o', '', 'pficon') +
          '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
          __('Sorry but no templates were configured.') +
          '</div>'
      );
    },
  });
}

function filter_by_level(item) {
  var level = $(item).val();

  // Note that class names don't map to log level names (label-info == notice)
  if (level == 'info') {
    $(
      '.label-info.result-filter-tag, ' +
        '.label-default.result-filter-tag, ' +
        '.label-warning.result-filter-tag, ' +
        '.label-danger.result-filter-tag, ' +
        '.label-success.result-filter-tag'
    )
      .closest('tr')
      .show();
  }
  if (level == 'notice') {
    $(
      '.label-info.result-filter-tag, .label-warning.result-filter-tag, .label-danger.result-filter-tag'
    )
      .closest('tr')
      .show();
    $('.label-default.result-filter-tag, .label-success.result-filter-tag')
      .closest('tr')
      .hide();
  }
  if (level == 'warning') {
    $('.label-warning.result-filter-tag, .label-danger.result-filter-tag')
      .closest('tr')
      .show();
    $(
      '.label-info.result-filter-tag, .label-default.result-filter-tag, .label-success.result-filter-tag'
    )
      .closest('tr')
      .hide();
  }
  if (level == 'error') {
    $('.label-danger.result-filter-tag')
      .closest('tr')
      .show();
    $(
      '.label-info.result-filter-tag, ' +
        '.label-default.result-filter-tag, ' +
        '.label-warning.result-filter-tag, ' +
        '.label-success.result-filter-tag'
    )
      .closest('tr')
      .hide();
  }
  if (
    $('#report_log tr:visible ').length == 1 ||
    ($('#report_log tr:visible ').length == 2 && $('#ntsh:visible').length > 0)
  ) {
    $('#ntsh').show();
  } else {
    $('#ntsh').hide();
  }
}
function show_release(element) {
  var os_family = $(element).val();
  if ($.inArray(os_family, ['Debian', 'Solaris', 'Coreos']) != -1) {
    $('#release_name').show();
  } else {
    $('#release_name').hide();
  }
}
// return a hash with values of all attributes
function attribute_hash(attributes) {
  var attrs = {};
  for (i = 0; i < attributes.length; i++) {
    var attr = $('*[id$=' + attributes[i] + ']');
    if (attr.length > 0) {
      if (attr.attr('type') == 'checkbox') {
        attrs[attributes[i]] = [];
        $('*[id*=' + attributes[i] + ']:checked').each(function(index, item) {
          attrs[attributes[i]].push($(item).val());
        });
      } else {
        if (attr.length > 1) {
          // select2 adds a div, so now we have a select && div
          attrs[attributes[i]] = $(
            $.grep(attr, function(a) {
              return $(a).is('select');
            })
          ).val();
        } else {
          if (attr.val() != null) attrs[attributes[i]] = attr.val();
        }
      }
    }
  }
  return attrs;
}

function ignore_subnet(item) {
  $(item).tooltip('hide');
  $(item)
    .closest('.accordion-group')
    .remove();
}

// shows provisioning templates in a new window
$(function() {
  $('[data-provisioning-template=true]').click(function() {
    window.open(this.href, [
      (width = '300'),
      (height = '400'),
      (scrollbars = 'yes'),
    ]);
    return false;
  });
});

function update_puppetclasses(element) {
  var host_id = $('form').data('id');
  var url = $(element).attr('data-url');
  var data = serializeForm().replace('method=patch', 'method=post');

  if (element.value == '') return;
  if (url.match('hostgroups')) {
    data = data + '&hostgroup_id=' + host_id;
  } else {
    data = data + '&host_id=' + host_id;
  }

  tfm.tools.showSpinner();
  $.ajax({
    type: 'post',
    url: url,
    data: data,
    success: function(request) {
      $('#puppet_klasses').html(request);
      reload_puppetclass_params();
      tfm.tools.activateTooltips();
      tfm.hostgroups.checkForUnavailablePuppetclasses();
    },
    complete: function() {
      reloadOnAjaxComplete(element);
    },
  });
}

function spinner_placeholder(text) {
  if (text == undefined) text = '';
  return (
    "<div class='spinner-placeholder'><p class='spinner-label'>" +
    text +
    "</p><div id='Loading' class='spinner spinner-md spinner-inline'> </div></div>"
  );
}

function typeToIcon(type) {
  switch (type) {
    case 'success':
      return tfm.tools.iconText('ok', __('Success') + ': ', 'pficon');
    case 'warning':
      return tfm.tools.iconText(
        'warning-triangle-o',
        __('Warning') + ': ',
        'pficon'
      );
    case 'danger':
      return tfm.tools.iconText('error-circle-o', __('Error') + ': ', 'pficon');
  }
}

function filter_permissions(item) {
  var term = $(item)
    .val()
    .trim();
  if (term.length > 0) {
    $('.form-group .collapse')
      .parents('.form-group')
      .hide();
    $(".form-group .control-label:icontains('" + term + "')")
      .parents('.form-group')
      .show();
  } else {
    $('.form-group .collapse')
      .parents('.form-group')
      .show();
  }
}

function setPowerState(item, status) {
  var power_actions = $('#power_actions'),
    loading_power_state = $('#loading_power_state');

  if (status == 'success') {
    var place_holder = loading_power_state.parent('.btn-group');
    power_actions.find('.btn-sm').removeClass('btn-sm');
    if (power_actions.find('.btn-group').exists()) {
      power_actions.contents().replaceAll(place_holder);
    } else {
      power_actions.contents().appendTo(place_holder);
      loading_power_state.remove();
    }
  } else {
    loading_power_state.text(__('Unknown power state'));
  }
  power_actions.hide();
  tfm.tools.activateTooltips();
}

function toggle_input_group(item) {
  item = $(item);
  var formControl = item.closest('.input-group').find('.form-control');
  if ($(formControl).is(':disabled')) {
    $(formControl).prop('disabled', false);
    $(formControl).attr('placeholder', '');
    $(item).blur();
  } else $(formControl).prop('disabled', true);
}

function reloadOnAjaxComplete(element) {
  tfm.tools.hideSpinner();
  tfm.tools.activateTooltips();
  activate_select2(':root');
  tfm.numFields.initAll();
  tfm.advancedFields.initAdvancedFields();
  tfm.templateInputs.initTypeChanges();
}

function set_fullscreen(element) {
  var exit_button = $(
    '<div class="exit-fullscreen"><a class="btn btn-default btn-lg" href="#" onclick="exit_fullscreen(); return false;" title="' +
      __('Exit Full Screen') +
      '">' +
      tfm.tools.iconText('compress', '', 'fa') +
      '</a></div>'
  );
  element
    .before("<span id='fullscreen-placeholder'></span>")
    .data('position', $(window).scrollTop())
    .addClass('fullscreen')
    .appendTo($('.container-pf-nav-pf-vertical'))
    .resize()
    .after(exit_button);
  $('#content').addClass('hidden');
  $(document).on('keyup', function(e) {
    if (e.keyCode == 27) {
      // esc
      exit_fullscreen();
    }
  });
}

function exit_fullscreen() {
  var element = $('.fullscreen');
  $('#content').removeClass('hidden');
  element
    .removeClass('fullscreen')
    .insertAfter('#fullscreen-placeholder')
    .resize();
  $('#fullscreen-placeholder').remove();
  $('.exit-fullscreen').remove();
  $(window).scrollTop(element.data('position'));
}

function disableButtonToggle(item, explicit) {
  if (explicit === undefined) {
    explicit = true;
  }

  item = $(item);
  item.attr('data-explicit', explicit);
  var isActive = item.hasClass('active');
  var formControl = item.closest('.input-group').find('.form-control');
  if (!isActive) {
    var blankValue = formControl.children("option[value='']");
    if (blankValue.length == 0) {
      $(item).attr('data-no-blank', true);
      $(formControl).append("<option value='' />");
    }
  } else {
    var blankAttr = item.attr('data-no-blank');
    if (blankAttr == 'true') {
      $(formControl)
        .children("[value='']")
        .remove();
    }
  }

  formControl.attr('disabled', !isActive);
  if (!isActive) {
    $(formControl).val('');
  }

  $(item).blur();
}

function activate_select2(container, allowClear) {
  allowClear = typeof allowClear !== 'undefined' ? allowClear : true;
  $(container)
    .find('select:not(.without_select2)')
    .not('.form_template select')
    .not('#interfaceForms select')
    .select2({ allowClear: allowClear });
}

function setError(field, text) {
  var form_group = field.parents('.form-group').first();
  form_group.addClass('has-error');
  var help_block = form_group.children('.help-inline').first();
  var span = $(document.createElement('span'));
  span.addClass('error-message').html(text);
  help_block.prepend(span);
}

function clearError(field) {
  var form_group = field.parents('.form-group').first();
  form_group.removeClass('has-error');
  var error_block = form_group
    .children('.help-inline')
    .children('.error-message');
  error_block.remove();
}
