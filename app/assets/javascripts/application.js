//= require jquery
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
//= require jquery.extentions
//= require jquery.multi-select
//= require settings

$(document).on('ContentLoad', function(){onContentLoad()});

$(function() {
  $(document.body).trigger('ContentLoad');
});

function onContentLoad(){
  if($('.autocomplete-clear').size() == 0){
    $('.autocomplete-input').scopedSearch();
    $('.ui-helper-hidden-accessible').remove();
  }

  $('.flash.error').each(function(index, item) {
     if ($('.alert.alert-danger.base').length == 0) {
       if ($('#host-conflicts-modal').length == 0) {
         notify(item, 'error');
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
  $("#title_action a").addClass("btn btn-default");
  $("#title_action li a").removeClass("btn btn-default").addClass("la");
  $("#title_action span").removeClass("btn btn-default").addClass("btn-group");
  $("#title_action a[href*='new']").removeClass('btn-default').addClass("btn-success");

  if ($("#login-form").size() > 0) {
    $("#login_login").focus();
    return false;
  }

  // highlight tabs with errors
  $(".tab-content").find(".form-group.has-error").each(function() {
    var id = $(this).parentsUntil(".tab-content").last().attr("id");
    $("a[href=#"+id+"]").addClass("tab-error");
  })

  //set the tooltips
  $('a[rel="popover"]').popover({html: true});
  $('[rel="twipsy"]').tooltip();
  $('*[title]').not('*[rel]').tooltip();
  $('[data-table=inline]').not('.dataTable').dataTable(
      {
        "sDom": "<'row'<'col-md-6'f>r>t<'row'<'col-md-6'i><'col-md-6'p>>",
        "sPaginationType": "bootstrap"
      }
  );

  // Prevents all links with the disabled attribute set to "disabled"
  // from being clicked.
  $('a[disabled="disabled"]').click(function() {
    return false;
  });

  // allow opening new window for selected links
  $('a[rel="external"]').click( function() {
    window.open( $(this).attr('href') );
    return false;
  });

  $('*[data-ajax-url]').each(function() {
    var url = $(this).data('ajax-url');
    $(this).load(url, function(response, status, xhr) {
      if (status == "error") {
        $(this).closest(".tab-content").find("#spinner").html(__('Failed to fetch: ') + xhr.status + " " + xhr.statusText);
      }
      if ($(this).data('on-complete')){
        window[$(this).data('on-complete')].call(null, this, status);
      }
    });
  });

  multiSelectOnLoad();
}

function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
  mark_params_override();
}

function mark_params_override(){
  $('#inherited_parameters .override-param').removeClass('override-param');
  $('#inherited_parameters span').show();
  $('#parameters').find('[id$=_name]:visible').each(function(){
    var param_name = $(this);
    $('#inherited_parameters').find('[id^=name_]').each(function(){
      if (param_name.val() == $(this).text()){
        $(this).addClass('override-param');
        $(this).closest('tr').find('textarea').addClass('override-param')
        $(this).closest('tr').find('[data-tag=override]').hide();
      }
    })
  })
  $('#inherited_puppetclasses_parameters .override-param').removeClass('override-param');
  $('#inherited_puppetclasses_parameters [data-tag=override]').show();
  $('#puppetclasses_parameters').find('[data-property=class]:visible').each(function(){
    var klass = $(this).val();
    var name = $(this).siblings('[data-property=name]').val();
    $('#inherited_puppetclasses_parameters [id^="puppetclass_"][id*="_params\\["][id$="\\]"]').each(function(){
      var param = $(this);
      if (param.find('[data-property=class]').text() == klass && param.find('[data-property=name]').text() == name) {
        param.find('.error').removeClass('error');
        param.find('.warning').removeClass('warning');
        param.addClass('override-param');
        param.find('input, textarea').addClass('override-param');
        param.find('[data-tag=override]').hide();
      }
    });
  });
  $('#params-tab').removeClass("tab-error");
  if ($("#params").find('.form-group.error').length > 0) $('#params-tab').addClass('tab-error');
  $('a[rel="popover"]').popover({html: true});
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).before(content.replace(regexp, new_id));
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
    },
    error: function(jqXHR, textStatus, errorThrown) {
      $(div).html('<div class="alert alert-warning alert-dismissable">' +
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
  if($("#report_log tr:visible ").size() ==1 || $("#report_log tr:visible ").size() ==2 && $('#ntsh:visible').size() > 0 ){
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
  if (os_family == 'Debian' || os_family == 'Solaris') {
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
    if (attr.size() > 0) {
      if(attr.attr("type")=="checkbox"){
        attrs[attributes[i]] = [];
        $("*[id*="+attributes[i]+"]:checked").each(function(index,item){
          attrs[attributes[i]].push($(item).val());
        })
      }else{
        if (attr.val() != null) attrs[attributes[i]] = attr.val();
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
  var env_id = $('*[id*=environment_id]').val();
  var url = $(element).attr('data-url');
  var data = $("form").serialize().replace('method=put', 'method=post');
  data = data + '&host_id=' + host_id
  if (env_id == "") return;
  $(element).indicator_show();
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
      $(element).indicator_hide();
    }
  })
}

// generates an absolute, needed in case of running Foreman from a subpath
function foreman_url(path) {
  return URL_PREFIX + path;
}

$.fn.indicator_show = function(){
 $(this).parents('.form-group').find('img').show();
}

$.fn.indicator_hide = function(){
 $(this).parents('.form-group').find('img').hide();
}

function spinner_placeholder(text){
  if (text == undefined) text = "";
  return "<div class='spinner-placeholder'>" + text + "</div>"
}

function notify(item, type) {
  var options = { type: type, sticky: (type != 'success') };
  $.jnotify($(item).text(), options);
  $(item).remove();
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
  $('[rel="twipsy"]').tooltip();
}
