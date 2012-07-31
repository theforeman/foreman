var $editor

$(function() {
  var template_text = $(".template_text");
  if ($.browser.msie && $.browser.version.slice(0,1) < 10) {
    $('.subnav').hide();
    if ($('.diffMode').size() >0) {
      IE_diff_mode(template_text);
    }
  }else{
    if (template_text.size() >0 ) { create_editor(template_text) };
    if ($('.diffMode').size() >0) {
      set_diff_mode(template_text);
    } else {
      set_edit_mode(template_text);
    }
    $('#config_template_submit').on('click', function(){
      if($('.diffMode').size() >0){ set_edit_mode( $(".template_text")); }
    })
  }

  $(".template_file").on("change", function(evt){
    if ($(".template_file").val() == "") return;

    if(window.File && window.FileList && window.FileReader)
    {
      var answer = confirm("You are about to override the editor content, Are You Sure?")
      if (!answer) { $('.template_file').val(""); return;}

      var files = evt.target.files; // files is a FileList object
      for (var i = 0, f; f = files[i]; i++) {
        var reader = new FileReader();
        // Closure to capture the file information.
        reader.onloadend = function(evt) {
          if (evt.target.readyState == FileReader.DONE) { // DONE == 2
            $('#new').text(( evt.target.result));
            set_edit_mode($('.template_text'));
          }
        };
        // Read in the file as text.
        reader.readAsText(f);
        $('.template_file').val("");
      }
    }else{
      //Set editor in read only mode
      $editor.setTheme("ace/theme/clouds");
      $editor.setReadOnly(true);
    }

  })

  $("#keybinding").on("change", function() {
    var vim = require("ace/keyboard/keybinding/vim").Vim;
    var emacs = require("ace/keyboard/keybinding/emacs").Emacs;
    var keybindings = {
      Default: null, // Null = use "default" keymapping
      Vim: vim,
      Emacs: emacs};

    $editor.setKeyboardHandler(keybindings[$("#keybinding").val()]);
  })
});

function snippet_changed(item){
  var checked = !!$(item).attr('checked');
  $('#kind_selector').toggle(!checked);
  $('#snippet_message').toggle(checked);
  $('#association').toggle(!checked);
}
function create_editor(item) {

  item.parent().prepend("<div id='editor1'></div>");

  $("#editor1")
      .css("position","relative")
      .height(item.height() || '360')
      .width(item.width());
  item.hide();

  $editor = ace.edit("editor1");
  $editor.setShowPrintMargin(false);
  $editor.renderer.setShowGutter(false);
}


function set_preview(){
  if($('.template_text').hasClass('diffMode')) return;
  $('.template_text').addClass('diffMode');
  $('#new').html( $editor.getSession().getValue());
  set_diff_mode($('.template_text'))
}

function set_code(){
  $('.template_text').removeClass('diffMode');
  set_edit_mode($('.template_text'));
}

function set_edit_mode(item){
  $editor.setTheme("ace/theme/twilight");
  $editor.setReadOnly(false);
  var RubyMode = require("ace/mode/ruby").Mode;
  var session = $editor.getSession();
  session.setMode(new RubyMode());

  session.setValue($('#new').text());
  session.on('change', function(){
    item.text(session.getValue());
  });
}


function set_diff_mode(item){
  $editor.setTheme("ace/theme/clouds");
  $editor.setReadOnly(true);
  var DiffMode = require("ace/mode/diff").Mode;
  var session = $editor.getSession();
  session.setMode(new DiffMode());
  var patch = JsDiff.createPatch(item.attr('data-file-name'), $('#old').text(), $('#new').text());
  $(session).off('change');
  session.setValue(patch);
}

function IE_diff_mode(item){
  var patch = JsDiff.createPatch(item.attr('data-file-name'), $('#old').contents().text() , $('#new').contents().text());
  item.val(patch);
  item.attr('readOnly', true);
}

function revert_template(item){
  var answer = confirm("You are about to override the editor content with a previous version, Are You Sure?")
  if (!answer) return;

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
        $('#new').text(res.responseText);
        set_edit_mode($('.template_text'));
      }
      var time = $(item).closest('div.row').find('h6 span').attr('data-original-title');
      $('#config_template_audit_comment').text("Revert to revision from: " + time)
    }
  })
}