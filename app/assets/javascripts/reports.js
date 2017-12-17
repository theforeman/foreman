$(function() {
  var source = $('td:contains("---")');

  source.contents().wrap("<div class='origin'></div>");
  source.prepend("<a href='#' onclick='show_diff(this)' >" + __('View Diff') + '</a>');
  $('.origin').hide();
});

function show_diff(item) {
  var patch = $(item)
    .parent('td')
    .find('.origin')
    .text();
  $('#diff-modal').modal({ show: true });
  $('#diff-modal-editor')
    .css('position', 'relative')
    .css('padding-top', '0')
    .height('380px');

  var editor = ace.edit('diff-modal-editor');
  editor.setTheme('ace/theme/clouds');
  editor.setReadOnly(true);
  editor.getSession().setMode('ace/mode/diff');
  editor.getSession().setValue(patch);
  editor.setShowPrintMargin(false);
  editor.renderer.setShowGutter(false);
  return false;
}

function filter_by_level(item) {
  var level = $(item).val();

  // Note that class names don't map to log level names (label-info == notice)
  if (level == 'info') {
    $(
      '.label-info.result-filter-tag, ' +
        '.label-default.result-filter-tag, ' +
        '.label-warning.result-filter-tag, ' +
        '.label-danger.result-filter-tag, ' +
        '.label-success.result-filter-tag',
    )
      .closest('tr')
      .show();
  }
  if (level == 'notice') {
    $(
      '.label-info.result-filter-tag, .label-warning.result-filter-tag, .label-danger.result-filter-tag',
    )
      .closest('tr')
      .show();
    $('.label-default.result-filter-tag, .label-success.result-filter-tag')
      .closest('tr')
      .hide();
  }
  if (level == 'warning') {
    $('.label-warning.result-filter-tag, .label-danger.result-filter-tag')
      .closest('tr')
      .show();
    $(
      '.label-info.result-filter-tag, .label-default.result-filter-tag, .label-success.result-filter-tag',
    )
      .closest('tr')
      .hide();
  }
  if (level == 'error') {
    $('.label-danger.result-filter-tag')
      .closest('tr')
      .show();
    $(
      '.label-info.result-filter-tag, ' +
        '.label-default.result-filter-tag, ' +
        '.label-warning.result-filter-tag, ' +
        '.label-success.result-filter-tag',
    )
      .closest('tr')
      .hide();
  }
  if (
    $('#report_log tr:visible ').length == 1 ||
    ($('#report_log tr:visible ').length == 2 && $('#ntsh:visible').length > 0)
  ) {
    $('#ntsh').show();
  } else {
    $('#ntsh').hide();
  }
}
