$(function() {
  onContentLoad();
});

function onContentLoad(){
  $('.flash.error').hide().each(function(index, item) {
     if ($('.alert-message.alert-error.base').length == 0) {
       if ($('#host-conflicts-modal').length == 0) {
         $.jnotify($(item).text(), { type: "error", sticky: true });
       }
     }
   });

   $('.flash.warning').hide().each(function(index, item) {
     $.jnotify($(item).text(), { type: "warning", sticky: true });
   });

   $('.flash.notice').hide().each(function(index, item) {
     $.jnotify($(item).text(), { type: "success", sticky: false });
   });

  // adds buttons classes to all links
  $("#title_action a").addClass("btn");
  $("#title_action a[href*='new']").addClass("btn-success");

  // highlight tabs with errors
  $(".tab-content").find(".control-group.error").each(function() {
    var id = $(this).parentsUntil(".tab-content").last().attr("id");
    $("a[href=#"+id+"]").addClass("tab-error");
  })

  //set the tooltips
  $('a[rel="popover"]').popover();
  $('[rel="twipsy"]').tooltip();
}


function remove_fields(link) {
  $(link).prev("input[type=hidden]").val("1");
  $(link).closest(".fields").hide();
}

function add_fields(link, association, content) {
  var new_id = new Date().getTime();
  var regexp = new RegExp("new_" + association, "g");
  $(link).parent().before(content.replace(regexp, new_id));
}

function checkAll (id, checked) {
  $(id).attr('checked',checked);
}

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

// allow opening new window for selected links
$(function() {
  $('a[rel="external"]').click( function() {
    window.open( $(this).attr('href') );
    return false;
  });
});

function template_info(div, url) {
  os_id = $("#host_operatingsystem_id :selected").attr("value");
  env_id = $("#host_environment_id :selected").attr("value");
  hostgroup_id = $("#host_hostgroup_id :selected").attr("value");
  build = $('input:radio[name$="[build]"]:checked').val();

  $(div).html('<img src="/images/spinner.gif" alt="Wait" />');
  $(div).load(url + "?operatingsystem_id=" + os_id + "&hostgroup_id=" + hostgroup_id + "&environment_id=" + env_id+"&provisioning="+build,
              function(response, status, xhr) {
                if (status == "error") {
                  $(div).html("<div class='alert alert-warning'><a class='close' data-di  smiss='alert'>&times;</a><p>Sorry but no templates were configured.</p></div>");
                }
              });
}

$(document).ready(function() {
  var common_settings = {
    method      : 'PUT',
    indicator   : "<img src='../images/spinner.gif' />",
    tooltip     : 'Click to edit..',
    placeholder : 'Click to edit..',
    submitdata  : {authenticity_token: AUTH_TOKEN, format : "json"},
    onedit      : function(data) { $(this).removeClass("editable"); },
    callback    : function(value, settings) { $(this).addClass("editable"); },
    onsuccess   :  function(data) {
      var parsed = $.parseJSON(data);
      var key = $(this).attr('name').split("[")[0];
      var val = $(this).attr('data-field');
      $(this).html(String(parsed[key][val]));
    },
    onerror     : function(settings, original, xhr) {
      original.reset();
      var error = $.parseJSON(xhr.responseText)["errors"];
      $.jnotify(error, { type: "error", sticky: true });
    }
  };

  $('.edit_textfield').each(function() {
    var settings = {
      type : 'text',
      name : $(this).attr('name'),
      width: '95%'
    };
    $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
  });

  $('.edit_textarea').each(function() {
    var settings = {
      type : 'textarea',
      name : $(this).attr('name'),
      rows : 8,
      cols : 36
    };
    $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
  });

  $('.edit_select').each(function() {
    var settings = {
      type : 'select',
      name : $(this).attr('name'),
      data : $(this).attr('select_values'),
      submit : 'Save'
    };
    $(this).editable($(this).attr('data-url'), $.extend(common_settings, settings));
  });
});

$(function() {
  if ($("#login-form").size() > 0) {
    $("#login_login").focus();
    $(".logo, .logo-text").hide();
    return false;
  }

  magic_line("#menu" , 1);
  magic_line("#menu2", 0);
  $('.dropdown-toggle').dropdown();
  $('.auto_complete_clear').addClass ('icon-remove');
});

function magic_line(id, combo) {
  var $el, leftPos, newWidth, $mainNav = $(id);

  $mainNav.append("<li class='magic-line'></li>");
  var $magicLine = $(id + " .magic-line");
  if ($('[data-toggle=collapse]:visible').length > 0){
    $magicLine.hide();
  }else{$magicLine.show();}
  if ( $(".active").size() > 0){
    $magicLine
    .width($(id +" .active").width() + $(id + " .active.dropdown").width() * combo)
    .css("left", $(".active").position().left)
    .data("origLeft", $magicLine.position().left)
    .data("origWidth", $magicLine.width());
  } else {
    $magicLine.width(0).css("left", 0)
    .data("origLeft", $magicLine.position().left)
    .data("origWidth", $magicLine.width());
  }
  $(id + " li").hover(function() {
    if ($('[data-toggle=collapse]:visible').length > 0){
      $magicLine.hide();
      return;
    }
    $magicLine.show();
    $el = $(this);
    if ($el.parent().hasClass("dropdown-menu")){
      $el=$el.parent().parent();
    }
    leftPos = $el.position().left;
    newWidth = $el.width();
    if ($el.find("a").hasClass("narrow-right")){
      newWidth = newWidth + $(".dropdown").width() * combo;
    }
    $magicLine.stop().animate({
      left: leftPos,
      width: newWidth
    });
  }, function() {
    if ($('[data-toggle=collapse]:visible').length > 0){
      $magicLine.hide();
    }else{
      $magicLine.stop().animate({
        left: $magicLine.data("origLeft"),
        width: $magicLine.data("origWidth")
      });
    }
  });
}

//add bookmark dialog
$(function() {
  $('#bookmarks-modal .btn-primary').click(function(){
    $("#bookmark_submit").click();
  });
  $("#bookmarks-modal").bind('shown', function () {
    var query = encodeURI($("#search").val());
    var url = $("#bookmark").attr('data-url');
    $("#bookmarks-modal .modal-body").empty();
    $("#bookmarks-modal .modal-body").append("<span id='loading'>Loading ...</span>");
    $("#bookmarks-modal .modal-body").load(url + '&query=' + query + ' form',
                                           function(response, status, xhr) {
                                             $("#loading").hide();
                                             $("#bookmarks-modal .modal-body .btn").hide()
                                           });
  });

});

function filter_by_level(item){
  var level = $(item).val();

  if(level == 'notice'){
    $('.label-info').closest('tr').show();
    $('.label-warning').closest('tr').show();
    $('.label-important').closest('tr').show();
  }
  if(level == 'warning'){
    $('.label-info').closest('tr').hide();
    $('.label-warning').closest('tr').show();
    $('.label-important').closest('tr').show();
  }
  if(level == 'error'){
    $('.label-info  ').closest('tr').hide();
    $('.label-warning').closest('tr').hide();
    $('.label-important').closest('tr').show();
  }
  if($("#report_log tr:visible ").size() ==1 || $("#report_log tr:visible ").size() ==2 && $('#ntsh:visible').size() > 0 ){
    $('#ntsh').show();
  }
  else{
    $('#ntsh').hide();
  }
}

function auth_source_selected(){
  var auth_source_id = $('#user_auth_source_id').attr('value');
  if (auth_source_id == '') return false;
  $.ajax({
    type:'get',
    url:'/users/auth_source_selected',
    data:'auth_source_id=' + auth_source_id
  })
}
function show_release(element){
  var os_family = $(element).val();
  if (os_family == 'Debian' || os_family == 'Solaris') {
    $("#release_name").show('highlight', 1000);
  } else {
    $("#release_name").hide();
  }
}
// return a hash with values of all attributes
function attribute_hash(attributes){
  var attrs = {};
  for (i=0;i < attributes.length; i++) {
    var attr = $('*[id*='+attributes[i]+']');
    if (attr.size() > 0) { attrs[attributes[i]] = attr.val(); }
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