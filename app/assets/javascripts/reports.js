$(function() {
  var source = $('td:contains("---")');

  source.contents().wrap("<div class='origin'></div>");
  source.prepend("<a href='#' onclick='show_diff(this)' >View Diff</a>");
  $('.origin').hide();

});

function show_diff(item){
  var patch = $(item).parent('td').find('.origin').text();
  $('#diff-modal').modal({show: true});
  $("#diff-modal-editor")
        .css("position","relative")
        .css("padding-top","0")
        .height('380')
        .width('680');

  var editor = ace.edit("diff-modal-editor");
  editor.setTheme("ace/theme/clouds");
  editor.setReadOnly(true);
  editor.getSession().setMode("ace/mode/diff");
  editor.getSession().setValue(patch);
  editor.setShowPrintMargin(false);
  editor.renderer.setShowGutter(false);
  return false;
}