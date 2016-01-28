//= require jquery
//= require jquery.turbolinks
//= require turbolinks
//= require i18n
//= require jquery_ujs
//= require jquery.ui.autocomplete
//= require scoped_search
//= require bootstrap
//= require multi-select
//= require charts
//= require topbar
//= require two-pane
//= require vendor
//= require about
//= require proxy_status
//= require proxy_status/dhcp
//= require jquery.extentions
//= require jquery.multi-select
//= require settings
//= require jquery.gridster
//= require hidden_values
//= require select_on_click
//= require select2
//= require underscore
//= require editor
//= require lookup_keys

window.foreman = window.foreman || {};
foreman.tools = foreman.tools || {};
foreman.tools.showSpinner = function() {
  $("#turbolinks-progress").show();
}

foreman.tools.hideSpinner = function() {
  $("#turbolinks-progress").hide();
}

$(document).on('ContentLoad', onContentLoad);

$(document).on("page:fetch", foreman.tools.showSpinner)

$(document).on("page:change", foreman.tools.hideSpinner)

$(window).bind('beforeunload', function() {
  $(".jnotify-container").remove();
});

$(function() {
  $(document).trigger('ContentLoad');
});

function onContentLoad(){
  uninitialized_autocompletes = $.grep($('.autocomplete-input'), function(i){ return !$(i).next().hasClass('autocomplete-clear'); });
  if (uninitialized_autocompletes.length > 0) {
    $.each(uninitialized_autocompletes, function(i, input) {$(input).scopedSearch({'delay': 250})});
    $('.ui-helper-hidden-accessible').remove();
  }

  $('.flash.error').each(function(index, item) {
     if ($('.alert.alert-danger.base').length == 0) {
       if ($('#host-conflicts-modal').length == 0) {
         notify(item, 'danger');
       }
     }
   });

   $('.flash.warning').each(function(index, item) {
     notify(item, 'warning');
   });

   $('.flash.notice').each(function(index, item) {
     notify(item, 'success');
   });

  // adds buttons classes to all links
  $("#title_action a").addClass('btn').not('.btn-info, .btn-danger').addClass("btn-default");

  $("#title_action li a").removeClass("btn btn-default").addClass("la");
  $("#title_action span").removeClass("btn btn-default").addClass("btn-group");
  $("#title_action a[href*='new']").removeClass('btn-default').addClass("btn-primary");

  if ($("input[focus_on_load=true]").length > 0) {
    $("input[focus_on_load]").first().focus();
  }

  // highlight tabs with errors
  var errorFields = $(".tab-content .has-error");
  errorFields.parents(".tab-pane").each(function() {
      $("a[href=#"+this.id+"]").addClass("tab-error");
  })
  $(".tab-error").first().click();
  $('.nav-pills .tab-error').first().click();
  errorFields.first().find('.form-control').focus();


  //set the tooltips
  $('a[rel="popover"]').popover();
  $('[rel="twipsy"]').tooltip({ container: 'body' });
  $('.ellipsis').tooltip({ container: 'body',
                           title: function(){return (this.scrollWidth > this.clientWidth) ? this.textContent : null;}
                        });
  $('*[title]').not('*[rel]').tooltip({ container: 'body' });
  activateDatatables();

  // Prevents all links with the disabled attribute set to "disabled"
  // from being clicked.
  $('a[disabled="disabled"]').click(function() {
    return false;
  });

  // allow opening new window for selected links
  $('a[rel="external"]').attr("target","_blank");

  $('*[data-ajax-url]').each(function() {
    var url = $(this).data('ajax-url');
    $(this).removeAttr('data-ajax-url');
    $(this).load(url, function(response, status, xhr) {
      if (status == "error") {
        if (!response.length){
          response = __('Failed to fetch: ') + xhr.status + " " + xhr.statusText;
        }
        $(this).html(response);
      }
      if ($(this).data('on-complete')){
        window[$(this).data('on-complete')].call(null, this, status);
      }
    });
  });

  multiSelectOnLoad();

  // Removes the value from fake password field.
  $("#fakepassword").val("");
  $('form').on('click', 'input[type="submit"]', function() {
    $("#fakepassword").remove();
  });

  password_caps_lock_hint();

  var tz = jstz.determine();
  $.cookie('timezone', tz.name(), { path: '/', secure: location.protocol === 'https:' });

  $('.full-value').SelectOnClick();
  $('select:not(.without_select2)').select2({ allowClear: true });

  $('input.remove_form_templates').closest('form').submit(function(event) {
    $(this).find('.form_template').remove()
  })
}

function activateDatatables() {
  $('[data-table=inline]').not('.dataTable').dataTable(
      {
        "sDom": "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>",
        "sPaginationType": "bootstrap"
      }
  );
}

function preserve_selected_options(elem) {
  // mark the selected values to preserve them for form hiding
  elem.find('option:not(:selected)').removeAttr('selected');
  elem.find('option:selected').attr('selected', 'selected');
}

function password_caps_lock_hint() {
  $('[type=password]').keypress(function(e) {
    var $addon         = $(this).parent().children('.input-addon'),
        key            = String.fromCharCode(e.which);

    if (check_caps_lock(key, e)){
      if (!$addon.is(':visible'))
        $addon.show();
    } else if ($addon.is(':visible')) {
      $addon.hide();
    }
  });
}

//Tests if letter is upper case and the shift key is NOT pressed.
function check_caps_lock(key, e) {
  return key.toUpperCase() === key && key.toLowerCase() !== key && !e.shiftKey
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
  mark_params_override();
}

function mark_params_override(){
  $('#inherited_parameters .override-param').removeClass('override-param');
  $('#parameters').find('[id$=_name]:visible').each(function(){
    var param_name = $(this);
    $('#inherited_parameters').find('[id^=name_]').each(function(){
      if (param_name.val() == $(this).text()){
        $(this).closest('tr').addClass('override-param');
      }
    });
  });
  $('#params-tab').removeClass("tab-error");
  if ($("#params").find('.form-group.error').length > 0) $('#params-tab').addClass('tab-error');
  $('a[rel="popover"]').popover();
}

function add_fields(target, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(target).append(content.replace(regexp, new_id));
}

$(document).ready(function() {
  $("#check_all_roles").click(function(e) {
      e.preventDefault();
      $(".role_checkbox").prop('checked', true);

  });

  $("#uncheck_all_roles").click(function(e) {
      e.preventDefault();
      $(".role_checkbox").prop('checked', false);
  });
});


function toggleCheckboxesBySelector(selector) {
  boxes = $(selector);
  var all_checked = true;
  for (i = 0; i < boxes.length; i++) { if (!boxes[i].checked) { all_checked = false; } }
  for (i = 0; i < boxes.length; i++) { boxes[i].checked = !all_checked; }
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
    type: "POST",
    url: url + "?provisioning=" + build,
    data: form,
    success: function(response, status, xhr) {
      $(div).html(response);
      $('select').select2({ allowClear: true });
    },
    error: function(jqXHR, textStatus, errorThrown) {
      $(div).html('<div class="alert alert-warning alert-dismissable">' +
          icon_text("warning-triangle-o", "", "pficon") +
        '<button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>' +
        __('Sorry but no templates were configured.') + '</div>');
    }
  });
}

//add bookmark dialog
$(function() {
  $('#bookmarks-modal .modal-footer .btn-primary').on('click', function(){
     $('#bookmarks-modal .modal-body .btn-primary').click();
  });
  $("#bookmarks-modal").bind('shown.bs.modal', function () {
    var query = encodeURI($("#search").val());
    var url = $("#bookmark").attr('data-url');
    $("#bookmarks-modal .modal-body").empty();
    $("#bookmarks-modal .modal-body").append("<span id='loading'>" + __('Loading ...') + "</span>");
    $("#bookmarks-modal .modal-body").load(url + '&query=' + query + ' form',
                                           function(response, status, xhr) {
                                             $("#loading").hide();
                                             $("#bookmarks-modal .modal-body .btn").hide()
                                           });
  });

});

function filter_by_level(item){
  var level = $(item).val();

  // Note that class names don't map to log level names (label-info == notice)
  if(level == 'info'){
    $('.label-info').closest('tr').show();
    $('.label-default').closest('tr').show();
    $('.label-warning').closest('tr').show();
    $('.label-danger').closest('tr').show();
  }
  if(level == 'notice'){
    $('.label-info').closest('tr').show();
    $('.label-default').closest('tr').hide();
    $('.label-warning').closest('tr').show();
    $('.label-danger').closest('tr').show();
  }
  if(level == 'warning'){
    $('.label-info').closest('tr').hide();
    $('.label-default').closest('tr').hide();
    $('.label-warning').closest('tr').show();
    $('.label-danger').closest('tr').show();
  }
  if(level == 'error'){
    $('.label-info').closest('tr').hide();
    $('.label-default').closest('tr').hide();
    $('.label-warning').closest('tr').hide();
    $('.label-danger').closest('tr').show();
  }
  if($("#report_log tr:visible ").length ==1 || $("#report_log tr:visible ").length ==2 && $('#ntsh:visible').length > 0 ){
    $('#ntsh').show();
  }
  else{
    $('#ntsh').hide();
  }
}

function auth_source_selected(){
  var auth_source_id = $('#user_auth_source_id').val();
  if (auth_source_id == '') {
     $("#password").hide();
  } else {
     $("#password").show();
  }
}

function show_release(element){
  var os_family = $(element).val();
  if ($.inArray(os_family, ['Debian', 'Solaris', 'Coreos']) != -1) {
    $("#release_name").show();
  } else {
    $("#release_name").hide();
  }
}
// return a hash with values of all attributes
function attribute_hash(attributes){
  var attrs = {};
  for (i=0;i < attributes.length; i++) {
    var attr = $('*[id$='+attributes[i]+']');
    if (attr.length > 0) {
      if(attr.attr("type")=="checkbox"){
        attrs[attributes[i]] = [];
        $("*[id*="+attributes[i]+"]:checked").each(function(index,item){
          attrs[attributes[i]].push($(item).val());
        })
      } else {
        if (attr.length > 1) {
          // select2 adds a div, so now we have a select && div
          attrs[attributes[i]] = $($.grep(attr, function(a) {
            return $(a).is("select");
          })).val();
        } else {
          if (attr.val() != null) attrs[attributes[i]] = attr.val();
        }
      }
    }
  }
  return attrs;
}

function ignore_subnet(item){
 $(item).tooltip('hide');
 $(item).closest('.accordion-group').remove();
}

function show_rdoc(item){
  var url = $(item).attr('data-url');
  window.open(url);
}

// shows provisioning templates in a new window
$(function() {
  $('[data-provisioning-template=true]').click(function(){
    window.open(this.href, [width='300',height='400',scrollbars='yes']);
    return false;
  });
});

function update_puppetclasses(element) {
  var host_id = $("form").data('id')
  var env_id = $('select[name*=environment_id]').val();
  var url = $(element).attr('data-url');
  var data = $("form").serialize().replace('method=patch', 'method=post');
  if (url.match('hostgroups')) {
    data = data + '&hostgroup_id=' + host_id
  } else {
    data = data + '&host_id=' + host_id
  }

  if (env_id == "") return;
  foreman.tools.showSpinner();
  $.ajax({
    type: 'post',
    url:  url,
    data: data,
    success: function(request) {
      $('#puppet_klasses').html(request);
      reload_puppetclass_params();
      $('[rel="twipsy"]').tooltip();
    },
    complete: function() {
      reloadOnAjaxComplete(element);
    }
  })
}

// generates an absolute, needed in case of running Foreman from a subpath
function foreman_url(path) {
  return URL_PREFIX + path;
}

function spinner_placeholder(text){
  if (text == undefined) text = "";
  return "<div class='spinner-placeholder'><p class='spinner-label'>" + text + "</p><div id='Loading' class='spinner spinner-md spinner-inline'> </div></div>";
}

function notify(item, type) {
  var icon = typeToIcon(type);
  var options = { classMessage: "foreman-alert",
                  classBackground: "",
                  sticky: (type != 'success'),
                  type: type };
  $.jnotify("</div>" + icon + $(item).text(), options);
  // jnotify does not support multiple classes passed via classMessage so added via jquery.
  $('.foreman-alert').addClass("alert alert-" + type);
  $(item).remove();
}

function typeToIcon(type) {
  switch(type)
  {
  case 'success':
    return icon_text("ok", __('Success') + ": ", "pficon")
  case 'warning':
    return icon_text("warning-triangle-o", __('Warning') + ": ", "pficon")
  case 'danger':
    return icon_text("error-circle-o", __('Error') + ": ", "pficon")
  }
}

function filter_permissions(item){
  var term = $(item).val().trim();
  if (term.length > 0) {
    $(".form-group .collapse").parents('.form-group').hide();
    $(".form-group .control-label:icontains('"+term+"')").parents('.form-group').show();
  } else{
    $(".form-group .collapse").parents('.form-group').show();
  }
}

function setPowerState(item, status){
  if(status=='success') {
    var place_holder = $('#loading_power_state').parent('.btn-group');
    var power_actions = $('#power_actions');
    power_actions.find('.btn-sm').removeClass('btn-sm');
    if (power_actions.find('.btn-group').exists()){
      power_actions.contents().replaceAll(place_holder);
    }else{
      power_actions.contents().appendTo(place_holder);
      $('#loading_power_state').remove();
    }
  }else{
    $('#loading_power_state').text(_('Unknown power state'))
  }
  power_actions.hide();
  $('[rel="twipsy"]').tooltip();
}

function toggle_input_group(item) {
  item =  $(item);
  var formControl = item.closest('.input-group').find('.form-control');
  if ($(formControl).is(':disabled') ) {
    $(formControl).prop('disabled', false);
    $(formControl).attr("placeholder", "");
    $(item).blur();
  }
  else
    $(formControl).prop('disabled', true);
}

function reloadOnAjaxComplete(element) {
  foreman.tools.hideSpinner()
  $('[rel="twipsy"]').tooltip();
  $('select:not(.without_select2)').select2({ allowClear: true });
}

function set_fullscreen(element){
  var exit_button = $('<div class="exit-fullscreen"><a class="btn btn-default btn-lg" href="#" onclick="exit_fullscreen(); return false;" title="'+
    __('Exit Full Screen')+'">' + icon_text('expand','','fa') + '</a></div>');
  element.before("<span id='fullscreen-placeholder'></span>")
         .data('position', $(window).scrollTop())
         .addClass('fullscreen')
         .appendTo($('#main'))
         .resize()
         .after(exit_button);
  $('#content').addClass('hidden');
  $('.navbar').addClass('hidden');
  $(document).on('keyup', function(e) {
    if (e.keyCode == 27) {    // esc
      exit_fullscreen();
    }
  });
}

function exit_fullscreen(){
  var element = $('.fullscreen');
  $('#content').removeClass('hidden');
  $('.navbar').removeClass('hidden');
  element.removeClass('fullscreen')
         .insertAfter('#fullscreen-placeholder')
         .resize();
  $('#fullscreen-placeholder').remove();
  $('.exit-fullscreen').remove();
  $(window).scrollTop(element.data('position'));
}

function set_fullscreen_editor (element, relativeTo){
  var $element = $(element);

  if (relativeTo) {
    $element = $(relativeTo).find(element);
  }

  $element.children().removeClass('hidden');

  $element.data('origin', $element.parent())
    .data('position', $(window).scrollTop())
    .addClass('fullscreen')
    .appendTo($('#main'))
    .resize();

  $('.navbar').not('.navbar-editor').addClass('hidden');

  $('.btn-fullscreen').addClass("hidden");
  $('.btn-exit-fullscreen').removeClass("hidden");

  $('#content').addClass('hidden');
  $(document).on('keyup', function(e) {
    if (e.keyCode == 27) {    // esc
      exit_fullscreen_editor();
    }
  });
  Editor.resize(true);
}

function exit_fullscreen_editor (){
  var element = $('.fullscreen');

  $('#content').removeClass('hidden');
  $('.navbar').removeClass('hidden');
  element.removeClass('fullscreen')
    .prependTo(element.data('origin'))
    .resize();

  $('.btn-exit-fullscreen').addClass("hidden");
  $('.btn-fullscreen').removeClass("hidden");

  $(window).scrollTop(element.data('position'));
  Editor.resize(true);
}

function disableButtonToggle(item, explicit) {
  if (explicit === undefined) {
    explicit = true;
  }

  item = $(item);
  item.attr('data-explicit', explicit);
  var isActive = item.hasClass("active");
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
      $(formControl).children("[value='']").remove();
    }
  }

  formControl.attr('disabled', !isActive);
  if (!isActive) {
    $(formControl).val('');
  }

  $(item).blur();
}

function icon_text(name, inner_text, icon_class) {
  "use strict";
  var icon = '<span class="' + icon_class + " " + icon_class + "-" + name + '"/>'
  icon += typeof inner_text === "" ? "" : "<strong>" + inner_text + "</strong>";
  return icon
}
