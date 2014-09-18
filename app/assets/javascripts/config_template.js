var $editor

$(document).on('ContentLoad', function(){onEditorLoad()});

$(document).on('click','#config_template_submit', function(){
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

$(document).keyup(function(e) {
  if (e.keyCode == 27) {    // esc
    exit_fullscreen();
  }
});

function onEditorLoad(){
  var template_text = $(".template_text");
   if ($.browser && $.browser.msie && $.browser.version.slice(0,1) < 10) {
     $('.subnav').hide();
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

  $editor.setKeyboardHandler(keybindings[$("#keybinding")[0].selectedIndex]);
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
    // Set editor to read only mode
    $editor.setTheme("ace/theme/clouds");
    $editor.setReadOnly(true);
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

  $("#editor1")
      .css("position","relative")
      .height(item.height() || '360')
      .width(item.width()+10)
      .css('top', '-20px');
  item.hide();

  $editor = ace.edit("editor1");
  $editor.setShowPrintMargin(false);
  $editor.renderer.setShowGutter(false);
  if (item.is(':disabled')) {
    $('.ace_text-input').attr('disabled', true)
  }
}

function set_fullscreen(){
  $('#main').append($("#editor1"));
  $("#editor1")
     .height($(window).height()-50)
     .width($('#content').width())
     .css('top', 10)
     .addClass('container');
  $('#content').hide();
  $('.navbar').addClass('hidden');
  $('.logo-bar').addClass('hidden');
  $editor.resize();
  $('#main').append($('.exit-fullscreen'));
  $('.exit-fullscreen').show();
  $(window).scrollTop();
}

function exit_fullscreen(){
  $(".template_text").show();
  $('#content').show();
  $('.navbar').removeClass('hidden');
  $('.logo-bar').removeClass('hidden');
  $(".template_text").parent().prepend($("#editor1"))
  $("#editor1")
      .height($(".template_text").height() || '360')
      .width($(".template_text").width()-16)
      .css('top', -20)
  $(".template_text").hide();
  $editor.resize();
  $('.exit-fullscreen').addClass('hidden');
}

function set_preview(){
  if($('.template_text').hasClass('diffMode')) return;
  $('.template_text').addClass('diffMode');
  $('#new').val($editor.getSession().getValue());
  set_diff_mode($('.template_text'))
}

function set_code(){
  $('.template_text').removeClass('diffMode');
  set_edit_mode($('.template_text'));
}

function set_edit_mode(item){
  if( $editor == undefined) return;
  $editor.setTheme("ace/theme/twilight");
  $editor.setReadOnly(false);
  var session = $editor.getSession();
  session.setMode("ace/mode/ruby");

  session.setValue($('#new').val());
  session.on('change', function(){
    item.text(session.getValue());
  });
}

function set_diff_mode(item){
  $editor.setTheme("ace/theme/clouds");
  $editor.setReadOnly(true);
  var session = $editor.getSession();
  session.setMode("ace/mode/diff");
  var patch = JsDiff.createPatch(item.attr('data-file-name'), $('#old').val(), $('#new').val());
  patch = patch.replace(/^(.*\n){0,4}/,'');
  if (patch.length == 0)
    patch = __("No changes")

  $(session).off('change');
  session.setValue(patch);
}

function submit_code() {
  if($('.template_text').hasClass('diffMode')) {
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
      $('#config_template_audit_comment').text(Jed.sprintf(__("Revert to revision from: %s"), time))
    }
  })
}
