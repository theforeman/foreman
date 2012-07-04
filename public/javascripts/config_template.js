var $editor

$(function() {
  var template_text = $(".template_text");
  if ($.browser.msie && $.browser.version.slice(0,1) < 9) {
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
  }

  $(".template_file").on("change", function(){
       if ($(".template_file").val() != ""){
         $("#edit_template_tab").hide();
         $("#history_tab").hide();
         $(".template_file").addClass('btn-success');
       }
  })

  $(".clear_file").on("click", function(){
    $(".template_file").val("");
    $("#edit_template_tab").show();
    $("#history_tab").show();
    $(".template_file").removeClass('btn-success');
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
  var patch = JsDiff.createPatch(item.attr('data-file-name'), $('#old').text(), $('#new').text());
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
        $editor.getSession().setValue(res.responseText);
        $('#edit_template_tab').click();
        var time = $(item).closest('div.row').find('h6 span').attr('data-original-title');
        $('#config_template_audit_comment').text("Revert to revision from: " + time)
    }
  })
}