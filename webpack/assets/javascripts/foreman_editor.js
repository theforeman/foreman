import $ from 'jquery';
import ace from 'brace';
require('brace/mode/javascript');
require('brace/mode/ruby');
require('brace/mode/html_ruby');
require('brace/mode/json');
require('brace/mode/sh');
require('brace/mode/xml');
require('brace/mode/yaml');
require('brace/mode/diff');
require('brace/theme/twilight');
require('brace/theme/clouds');
require('brace/keybinding/vim');
require('brace/keybinding/emacs');
require('brace/ext/searchbox');

let Editor;

$(document).on('ContentLoad', function () {
  onEditorLoad();
});

$(document).on('click', '#editor_submit', function () {
  if ($('.diffMode').exists()) {
    setEditMode($('.editor_source'));
  }
});

$(document).on('change', '.editor_file_source', function (e) {
  if ($('.editor_file_source').val() !== '') {
    editorFileSource(e);
  }
});

$(document).on('change', '#keybinding', function () {
  setKeybinding();
});

$(document).on('change', '#mode', function () {
  setMode();
});

function onEditorLoad() {
  let editorSource = $('.editor_source');

  if (editorSource.exists()) {
    createEditor();
    if ($('.diffMode').exists()) {
      setDiffMode(editorSource);
    } else {
      setEditMode(editorSource);
    }
  }
}

function setKeybinding() {
  const keybindings = [
    null, // Null = use "default" keymapping
    'ace/keyboard/vim',
    'ace/keyboard/emacs'
  ];

  Editor.setKeyboardHandler(keybindings[$('#keybinding')[0].selectedIndex]);
}

function setMode(mode) {
  let session = Editor.getSession();
  const modes = [
    'ace/mode/text',
    'ace/mode/json',
    'ace/mode/ruby',
    'ace/mode/html_ruby',
    'ace/mode/javascript',
    'ace/mode/sh',
    'ace/mode/xml',
    'ace/mode/yaml'
  ];

  if (mode) {
    if (modes.indexOf(mode) >= 0) {
      $('#mode').val(mode.replace('ace/mode/', ''));
    }
  } else {
    mode = modes[$('#mode')[0].selectedIndex];
  }

  session.setMode(mode);
}

export function showImporter() {
  $('.editor_file_source').click();
}

/* eslint-disable max-statements, no-alert */
function editorFileSource(evt) {
  if (window.File && window.FileList && window.FileReader) {
    if (!confirm(__('You are about to override the editor content, are you sure?'))) {
      $('.editor_file_source').val('');
      return;
    }

    const files = evt.target.files; // files is a FileList object

    for (let f of files) {
      let reader = new FileReader();
      // Closure to capture the file information.

      reader.onloadend = function (evt) {
        if (evt.target.readyState === FileReader.DONE) { // DONE == 2
          $('#new').val((evt.target.result));
          setEditMode($('.editor_source'));
        }
      };
      // Read in the file as text.
      reader.readAsText(f);
      $('.editor_file_source').val('');
      $('.navbar-editor input[type="radio"]').blur();
      $('.navbar-editor #option1').click();
    }
  } else {
    // Browser can't read the file content,
    // the file will be uploaded to the server on form submit.
    // SetEditor to read only mode
    Editor.setTheme('ace/theme/clouds');
    Editor.setReadOnly(true);
  }
}

export function snippetChanged(item) {
  let checked = $(item).is(':checked');

  $('#kind_selector').toggle(!checked);
  $('#snippet_message').toggle(checked);
  $('#association').toggle(!checked);
}

function createEditor() {
  let editorId = 'editor-' + Math.random(),
    $editorContainer = $('.editor-container'),
    $editorSource = $editorContainer.find('.editor_source');

  $editorContainer.append('<div id="' + editorId + '" class="editor"></div>');
  $editorSource.hide();

  Editor = ace.edit(editorId);
  Editor.$blockScrolling = Infinity;
  Editor.setShowPrintMargin(false);
  Editor.renderer.setShowGutter(false);
  setMode('ace/mode/ruby');
  $(document).on('resize', editorId, function () {
    Editor.resize();
  });
  if ($editorSource.is(':disabled')) {
    Editor.setReadOnly(true);
  }
  if ($editorSource.hasClass('masked-input')) {
    $editorContainer.find('.ace_content').addClass('masked-input');
  }
}

export function setPreview() {
  if ($('.editor_source').hasClass('diffMode')) {
    return;
  }
  $('#preview_host_selector').hide();
  if ($('.editor_source').hasClass('renderMode')) { // coming from renderMode, don't store code
    $('.editor_source').removeClass('renderMode');
  } else {
    $('#new').val(Editor.getSession().getValue());
  }
  $('.editor_source').addClass('diffMode');
  setDiffMode($('.editor_source'));
}

export function setCode() {
  $('#preview_host_selector').hide();
  $('.editor_source').removeClass('diffMode renderMode');
  setEditMode($('.editor_source'));
}

export function setRender() {
  if ($('.editor_source').hasClass('renderMode')) {
    return;
  }
  $('#preview_host_selector').show();
  if ($('.editor_source').hasClass('diffMode')) { // coming from diffMode, don't store code
    $('.editor_source').removeClass('diffMode');
  } else {
    $('#new').val(Editor.getSession().getValue());
  }
  $('.editor_source').addClass('renderMode');
  setRenderMode();
}

function setEditMode(item) {
  if (Editor === undefined) {
    return;
  }
  Editor.setTheme('ace/theme/twilight');
  if (!item.is(':disabled')) {
    Editor.setReadOnly(false);
  }

  setMode('ace/mode/ruby');

  let session = Editor.getSession();

  session.setValue($('#new').val());
  session.on('change', function () {
    item.text(session.getValue());
  });
}

function setDiffMode(item) {
  Editor.setTheme('ace/theme/clouds');
  Editor.setReadOnly(true);
  let session = Editor.getSession();

  session.setMode('ace/mode/diff');
  const JsDiff = require('diff');
  let patch = JsDiff.createPatch(item.attr('data-file-name'), $('#old').val(), $('#new').val());

  patch = patch.replace(/^(.*\n){0,4}/, '');
  if (patch.length === 0) {
    patch = __('No changes');
  }

  $(session).off('change');
  session.setValue(patch);
}

function setRenderMode() {
  Editor.setTheme('ace/theme/twilight');
  Editor.setReadOnly(true);
  let session = Editor.getSession();

  session.setMode('ace/mode/text');
  $(session).off('change');
  getRenderedTemplate();
}

export function getRenderedTemplate() {
  let
    session = Editor.getSession(),
    hostId = $('#preview_host_id').select2('val'),
    url = $('.editor_source').data('render-path'),
    template = $('#new').val(),
    params = {
      template: template
    };

  if (hostId != null) {
    /* eslint-disable camelcase */
    params.preview_host_id = hostId;
  }

  session.setValue(__('Rendering the template, please wait...'));
  $.post(url, params, function (response) {
    $('div#preview_error').hide();
    $('div#preview_error span.text').html('');
    session.setValue(response);
  }).fail(function (response) {
    $('div#preview_error span.text').html(response.responseText);
    $('div#preview_error').show();
    session.setValue(__(
      'There was an error during rendering, return to the Code tab to edit the template.'
    ));
  });
}

export function submitCode() {
  if ($('.editor_source').is('.diffMode,.renderMode')) {
    setCode();
  }
}

/* eslint-disable max-len */
export function revertTemplate(item) {
  if (!confirm(__('You are about to override the editor content with a previous version, are you sure?'))) {
    return;
  }

  let version = $(item).attr('data-version');
  let url = $(item).attr('data-url');

  $.ajax({
    type: 'get',
    url: url,
    data: 'version=' + version,
    complete: function (res) {
      $('#primary_tab').click();
      if ($('#new').length) {
        $('#new').val(res.responseText);
        setEditMode($('.editor_source'));
      }
      let time = $(item).closest('div.row').find('h6 span').attr('data-original-title');

      $('#provisioning_template_audit_comment').text(
        /* eslint-disable no-undef */
        Jed.sprintf(__('Revert to revision from: %s'), time)
      );
    }
  });
}

export function enterFullscreen(element, relativeTo) {
  let $element = $(element);

  if (relativeTo) {
    $element = $(relativeTo).find(element);
  }

  $element.children().removeClass('hidden');
  $element.data('origin', $element.parent())
          .data('position', $(window).scrollTop())
          .addClass('fullscreen')
          .appendTo($('body'))
          .resize();

  $('.navbar').not('.navbar-editor').addClass('hidden');
  $('.btn-fullscreen').addClass('hidden');
  $('.btn-exit-fullscreen').removeClass('hidden');

  $('#content').addClass('hidden');
  $(document).on('keyup', function (e) {
      if (e.keyCode === 27) {    // esc
        exit_fullscreen_editor();
      }
  });
  Editor.resize(true);
}

export function exitFullscreen() {
  let element = $('.fullscreen');

  $('#content').removeClass('hidden');
  $('.navbar').removeClass('hidden');
  element.removeClass('fullscreen')
         .prependTo(element.data('origin'))
         .resize();

  $('.btn-exit-fullscreen').addClass('hidden');
  $('.btn-fullscreen').removeClass('hidden');
  $(window).scrollTop(element.data('position'));
  Editor.resize(true);
}
