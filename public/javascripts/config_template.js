
function snippet_changed(item){
  var checked = !!$(item).attr('checked');
  $('#kind_selector').toggle(!checked);
  $('#snippet_message').toggle(checked);
  $('#association').toggle(!checked);
}
$(function() {
  var text_area = $(".template_text");
  text_area.parent().prepend("<div id='editor1'></div>");

  $("#editor1")
      .css("position","relative")
      .height(text_area.height())
      .width(text_area.width());
  text_area.hide();

  var editor = ace.edit("editor1");
  editor.setTheme("ace/theme/twilight");
  editor.setShowPrintMargin(false);
  editor.renderer.setShowGutter(false);

  var RubyMode = require("ace/mode/ruby").Mode;
  var session = editor.getSession();
  session.setMode(new RubyMode());

  var content = text_area.text();
  session.setValue(content);
  session.on('change', function(){
    text_area.text(session.getValue());
  });

  $(".template_file").on("change", function(){
      if ($(".template_file").val() != ""){
        editor.setReadOnly(true);
        editor.setTheme("ace/theme/dawn");
        $(".template_file").addClass('btn-inverse');
      }
  })

  $(".clear_file").on("click", function(){
      $(".template_file").val("");
      editor.setReadOnly(false);
      editor.setTheme("ace/theme/twilight");
      $(".template_file").removeClass('btn-inverse');
      false;
  })

  if ($('#diffLines').size() >0) {
    editor.setTheme("ace/theme/clouds");
    editor.setReadOnly(true);
    var DiffMode = require("ace/mode/diff").Mode;
    session.setMode(new DiffMode());
    var patch = JsDiff.createPatch($('#diffLines').attr('data-file-name'), $('#old').text(), $('#new').text() );
    session.setValue(patch);
  }
});
