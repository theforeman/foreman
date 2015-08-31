var Editor;

$(document).on('ContentLoad', function(){onEditorLoad()});

$(document).on('click','#editor_submit', function(){
  if($('.diffMode').exists()){
    set_edit_mode( $(".editor_source"));
  }
});

$(document).on('change', '.editor_file_source', function(e){
  if ($('.editor_file_source').val() != '') editor_file_source(e);
});

$(document).on('change','#keybinding', function(){
  set_keybinding()
});

$(document).on('change','#mode', function(){
  set_mode()
});

function onEditorLoad(){
  var editor_source = $(".editor_source");
  if ($.browser && $.browser.msie && $.browser.version.slice(0,1) < 10) {
    if ($('.diffMode').exists()) {
      IE_diff_mode(editor_source);
    }
  }else{
    if (editor_source.exists()){
      create_editor();
    }

    if ($('.diffMode').exists()) {
      set_diff_mode(editor_source);
    } else {
      set_edit_mode(editor_source);
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

function set_mode () {
  var session = Editor.getSession();
  var modes = [
    "ace/mode/text",
    "ace/mode/json",
    "ace/mode/ruby",
    "ace/mode/sh",
    "ace/mode/xml",
    "ace/mode/yaml"
  ];

  session.setMode(modes[$("#mode")[0].selectedIndex]);
}

function editor_file_source(evt){
  if(window.File && window.FileList && window.FileReader)
  {
    if (!confirm(__("You are about to override the editor content, are you sure?"))) {
      $('.editor_file_source').val('');
      return;
    }

    var files = evt.target.files; // files is a FileList object
    for (var i = 0, f; f = files[i]; i++) {
      var reader = new FileReader();
      // Closure to capture the file information.
      reader.onloadend = function(evt) {
        if (evt.target.readyState == FileReader.DONE) { // DONE == 2
          $('#new').val((evt.target.result));
          set_edit_mode($('.editor_source'));
        }
      };
      // Read in the file as text.
      reader.readAsText(f);
      $('.editor_file_source').val("");
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

function create_editor() {
  var editorId = "editor-" + Math.random(),
    $editorContainer = $('.editor-container'),
    $editorSource = $editorContainer.find('.editor_source');

  $editorContainer.append('<div id="' + editorId + '" class="editor"></div>');
  $editorSource.hide();

  Editor = ace.edit(editorId);
  Editor.setShowPrintMargin(false);
  Editor.renderer.setShowGutter(false);
  $(document).on('resize', editorId, function(){Editor.resize()});
  if ($editorSource.is(':disabled')) {
    Editor.setReadOnly(true);
  }
}

function set_preview(){
  if($('.editor_source').hasClass('diffMode')) return;
  $("#preview_host_selector").hide();
  if ($('.editor_source').hasClass('renderMode')) { // coming from renderMode, don't store code
    $('.editor_source').removeClass('renderMode');
  } else {
    $('#new').val(Editor.getSession().getValue());
  }
  $('.editor_source').addClass('diffMode');
  set_diff_mode($('.editor_source'))
}

function set_code(){
  $("#preview_host_selector").hide();
  $('.editor_source').removeClass('diffMode renderMode');
  set_edit_mode($('.editor_source'));
}

function set_render() {
  if ($('.editor_source').hasClass('renderMode')) return;
  $("#preview_host_selector").show();
  if ($('.editor_source').hasClass('diffMode')) {  // coming from diffMode, don't store code
    $('.editor_source').removeClass('diffMode');
  } else {
    $('#new').val(Editor.getSession().getValue());
  }
  $('.editor_source').addClass('renderMode');
  set_render_mode();
}

function set_edit_mode(item){
  if( Editor == undefined) return;
  Editor.setTheme("ace/theme/twilight");
  if (!item.is(':disabled')) {
    Editor.setReadOnly(false);
  }

  set_mode("ace/mode/ruby");

  var session = Editor.getSession();
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
  url = $('.editor_source').data('render-path');
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
  if($('.editor_source').is('.diffMode,.renderMode')) {
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
        $('.editor_source').val(res.responseText);
      } else {
        $('#new').val(res.responseText);
        set_edit_mode($('.editor_source'));
      }
      var time = $(item).closest('div.row').find('h6 span').attr('data-original-title');
      $('#provisioning_template_audit_comment').text(Jed.sprintf(__("Revert to revision from: %s"), time))
    }
  })
}
