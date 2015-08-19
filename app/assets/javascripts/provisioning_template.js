var Editor;

$(document).on('ContentLoad', function(){onEditorLoad()});

$(document).on('click','#provisioning_template_submit', function(){
  if($('.diffMode').exists()){
    set_edit_mode( $(".template_text"));
  }
})

$(document).on('change', '.template_file', function(e){
  if ($('.template_file').val() != '') upload_file(e);
})

$(document).on('change','#keybinding', function(){
  set_keybinding()
})


function onEditorLoad(){
  var template_text = $(".template_text");
   if ($.browser && $.browser.msie && $.browser.version.slice(0,1) < 10) {
     if ($('.diffMode').exists()) {
       IE_diff_mode(template_text);
     }
   }else{
     if (template_text.exists()){
       create_editor(template_text)
     }

     if ($('.diffMode').exists()) {
       set_diff_mode(template_text);
     } else {
       set_edit_mode(template_text);
     }
   }
}

function set_keybinding(){
  var vim = require("ace/keyboard/vim").handler;
  var emacs = require("ace/keyboard/emacs").handler;
  var keybindings = [
    null, // Null = use "default" keymapping
    vim,
    emacs];

  Editor.setKeyboardHandler(keybindings[$("#keybinding")[0].selectedIndex]);
}

function upload_file(evt){
  if(window.File && window.FileList && window.FileReader)
  {
    if (!confirm(__("You are about to override the editor content, are you sure?"))) {
      $('.template_file').val('');
      return;
    }

    var files = evt.target.files; // files is a FileList object
    for (var i = 0, f; f = files[i]; i++) {
      var reader = new FileReader();
      // Closure to capture the file information.
      reader.onloadend = function(evt) {
        if (evt.target.readyState == FileReader.DONE) { // DONE == 2
          $('#new').val((evt.target.result));
          set_edit_mode($('.template_text'));
        }
      };
      // Read in the file as text.
      reader.readAsText(f);
      $('.template_file').val("");
    }
  }else{
    // Browser can't read the file content,
    // the file will be uploaded to the server on form submit.
    // SetEditor to read only mode
    Editor.setTheme("ace/theme/clouds");
    Editor.setReadOnly(true);
  }
}

function snippet_changed(item){
  var checked = !!$(item).attr('checked');
  $('#kind_selector').toggle(!checked);
  $('#snippet_message').toggle(checked);
  $('#association').toggle(!checked);
}

function create_editor(item) {
  item.parent().prepend("<div id='editor1'></div>");
  item.hide();
  Editor = ace.edit("editor1");
  Editor.setShowPrintMargin(false);
  Editor.renderer.setShowGutter(false);
  $(document).on('resize','#editor1', function(){Editor.resize()});
  if (item.is(':disabled')) {
    Editor.setReadOnly(true);
  }
}

function set_preview(){
  if($('.template_text').hasClass('diffMode')) return;
  $("#preview_host_selector").hide();
  if ($('.template_text').hasClass('renderMode')) { // coming from renderMode, don't store code
    $('.template_text').removeClass('renderMode');
  } else {
    $('#new').val(Editor.getSession().getValue());
  }
  $('.template_text').addClass('diffMode');
  set_diff_mode($('.template_text'))
}

function set_code(){
  $("#preview_host_selector").hide();
  $('.template_text').removeClass('diffMode renderMode');
  set_edit_mode($('.template_text'));
}

function set_render() {
  if ($('.template_text').hasClass('renderMode')) return;
  $("#preview_host_selector").show();
  if ($('.template_text').hasClass('diffMode')) {  // coming from diffMode, don't store code
    $('.template_text').removeClass('diffMode');
  } else {
    $('#new').val(Editor.getSession().getValue());
  }
  $('.template_text').addClass('renderMode');
  set_render_mode();
}

function set_edit_mode(item){
  if( Editor == undefined) return;
  Editor.setTheme("ace/theme/twilight");
  if (!item.is(':disabled')) {
    Editor.setReadOnly(false);
  }
  var session = Editor.getSession();
  session.setMode("ace/mode/ruby");

  session.setValue($('#new').val());
  session.on('change', function(){
    item.text(session.getValue());
  });
}

function set_diff_mode(item){
  Editor.setTheme("ace/theme/clouds");
  Editor.setReadOnly(true);
  var session = Editor.getSession();
  session.setMode("ace/mode/diff");
  var patch = JsDiff.createPatch(item.attr('data-file-name'), $('#old').val(), $('#new').val());
  patch = patch.replace(/^(.*\n){0,4}/,'');
  if (patch.length == 0)
    patch = __("No changes")

  $(session).off('change');
  session.setValue(patch);
}

function set_render_mode() {
  Editor.setTheme("ace/theme/twilight");
  Editor.setReadOnly(true);
  var session = Editor.getSession();
  session.setMode("ace/mode/text");
  $(session).off('change');
  get_rendered_template();
}

function get_rendered_template(){
  var session = Editor.getSession();
  host_id = $("#preview_host_selector select").val();
  url = $('.template_text').data('render-path');
  template = $('#new').val();
  params = { template: template };
  if (host_id != null) {
    params.preview_host_id = host_id
  }

  session.setValue(__('Rendering the template, please wait...'));
  $.post(url, params, function(response) {
    $("div#preview_error").hide();
    $("div#preview_error span.text").html('');
    session.setValue(response);
  }).fail(function(response){
    $("div#preview_error span.text").html(response.responseText);
    $("div#preview_error").show();
    session.setValue(__('There was an error during rendering, return to the Code tab to edit the template.'));
  });
}

function submit_code() {
  if($('.template_text').is('.diffMode,.renderMode')) {
    set_code();
  }
}

function IE_diff_mode(item){
  var patch = JsDiff.createPatch(item.attr('data-file-name'), $('#old').val(), $('#new').val());
  item.val(patch);
  item.attr('readOnly', true);
}

function revert_template(item){
  if (!confirm(__("You are about to override the editor content with a previous version, are you sure?"))) return;

  var version = $(item).attr('data-version');
  var url = $(item).attr('data-url');
  $.ajax({
    type: 'get',
    url:  url,
    data:'version=' + version,
    complete: function(res) {
      $('#primary_tab').click();
      if ($.browser.msie && $.browser.version.slice(0,1) < 10){
        $('.template_text').val(res.responseText);
      } else {
        $('#new').val(res.responseText);
        set_edit_mode($('.template_text'));
      }
      var time = $(item).closest('div.row').find('h6 span').attr('data-original-title');
      $('#provisioning_template_audit_comment').text(Jed.sprintf(__("Revert to revision from: %s"), time))
    }
  })
}
