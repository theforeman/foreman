/* eslint-disable no-undef */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-restricted-globals */
/* eslint-disable import/first */
import $ from 'jquery';
import * as ace from 'brace';

import 'brace/mode/ruby';
import 'brace/mode/json';
import 'brace/mode/sh';
import 'brace/mode/xml';
import 'brace/mode/yaml';
import 'brace/mode/diff';
import 'brace/theme/twilight';
import 'brace/theme/clouds';
import 'brace/keybinding/vim';
import 'brace/keybinding/emacs';
import 'brace/ext/searchbox';

import { initTypeAheadSelect } from './foreman_tools';

let Editor;

$(document).on('ContentLoad', onEditorLoad);

$(document).on('click', '#editor_submit', () => {
  if ($('.diffMode').exists()) {
    setEditMode($('.editor_source'));
  }
});

$(document).on('change', '.editor_file_source', (e) => {
  if ($('.editor_file_source').val() !== '') {
    editorFileSource(e);
  }
});

$(document).on('change', '#keybinding', () => {
  setKeybinding();
});

$(document).on('change', '#mode', () => {
  setMode();
});

function onEditorLoad() {
  const editorSource = $('.editor_source');
  if (editorSource.exists()) {
    createEditor();
    if ($('.diffMode').exists()) {
      setDiffMode(editorSource, $('#old').val(), $('#new').val());
    } else {
      setEditMode(editorSource);
    }

    initTypeAheadSelect($('#preview_host_id'));
  }
}

function setKeybinding() {
  const keybindings = [
    null, // Null = use "default" keymapping
    'ace/keyboard/vim',
    'ace/keyboard/emacs',
  ];

  Editor.setKeyboardHandler(keybindings[$('#keybinding')[0].selectedIndex]);
}

function setMode(mode, editor) {
  const modes = [
    'ace/mode/text',
    'ace/mode/json',
    'ace/mode/ruby',
    'ace/mode/html_ruby',
    'ace/mode/sh',
    'ace/mode/xml',
    'ace/mode/yaml',
  ];

  const session = (editor || Editor).getSession();

  if (mode) {
    if (modes.indexOf(mode) >= 0) {
      $('#mode').val(mode.replace('ace/mode/', ''));
    }
  } else {
    // eslint-disable-next-line no-param-reassign
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

    const { files } = evt.target; // files is a FileList object

    for (const f of files) {
      const reader = new FileReader();
      // Closure to capture the file information.

      // eslint-disable-next-line
      reader.onloadend = function (evt) {
        if (evt.target.readyState === FileReader.DONE) {
          // DONE == 2
          $('#new').val(evt.target.result);
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
  const checked = $(item).is(':checked');

  $('#kind_selector').toggle(!checked);
  $('#snippet_message').toggle(checked);
  $('#association').toggle(!checked);
  if (checked) {
    $('#ptable_os_family').val('');
    $('#ptable_os_family').trigger('change');
  }
}

function createEditor() {
  const editorId = `editor-${Math.random()}`;
  const $editorContainer = $('.editor-container');
  const $editorSource = $editorContainer.find('.editor_source');

  $editorContainer.append(`<div id="${editorId}" class="editor"></div>`);
  $editorSource.hide();

  Editor = ace.edit(editorId);
  Editor.$blockScrolling = Infinity;
  Editor.setShowPrintMargin(false);
  Editor.renderer.setShowGutter(false);
  setMode('ace/mode/ruby');
  $(document).on('resize', editorId, () => {
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
  if ($('.editor_source').hasClass('renderMode')) {
    // coming from renderMode, don't store code
    $('.editor_source').removeClass('renderMode');
  } else {
    $('#new').val(Editor.getSession().getValue());
  }
  $('.editor_source').addClass('diffMode');
  setDiffMode($('.editor_source'), $('#old').val(), $('#new').val());
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
  if ($('.editor_source').hasClass('diffMode')) {
    // coming from diffMode, don't store code
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

  const session = Editor.getSession();

  session.setValue($('#new').val());
  session.on('change', () => {
    item.text(session.getValue());
  });
}

function setDiffMode(item, oldVal, newVal, editor = Editor) {
  editor.setTheme('ace/theme/clouds');
  editor.setReadOnly(true);
  const session = editor.getSession();

  session.setMode('ace/mode/diff');
  const JsDiff = require('diff'); // eslint-disable-line global-require

  let patch = JsDiff.createPatch(item.attr('data-file-name'), oldVal, newVal);

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
  const session = Editor.getSession();

  session.setMode('ace/mode/text');
  $(session).off('change');
  getRenderedTemplate();
}

export function getRenderedTemplate() {
  const session = Editor.getSession();
  const hostId = $('#preview_host_id').select2('val');
  const url = $('.editor_source').data('render-path');
  const template = $('#new').val();
  const params = {
    template,
  };

  if (hostId != null) {
    /* eslint-disable camelcase */
    params.preview_host_id = hostId;
  }

  session.setValue(__('Rendering the template, please wait...'));
  $.post(url, params, (response) => {
    $('div#preview_error').hide();
    $('div#preview_error span.text').html('');
    session.setValue(response);
  }).fail((response) => {
    $('div#preview_error span.text').text(response.responseText);
    $('div#preview_error').show();
    session.setValue(__('There was an error during rendering, return to the Code tab to edit the template.'));
  });
}

export function submitCode() {
  if ($('.editor_source').is('.diffMode,.renderMode')) {
    setCode();
  }
}

/* eslint-disable max-len */
export function revertTemplate(item) {
  if (
    !confirm(__('You are about to override the editor content with a previous version, are you sure?'))
  ) {
    return;
  }

  const version = $(item).attr('data-version');
  const url = $(item).attr('data-url');

  $.ajax({
    type: 'get',
    url,
    data: `version=${version}`,
    complete(res) {
      $('#primary_tab').click();
      if ($('#new').length) {
        $('#new').val(res.responseText);
        setEditMode($('.editor_source'));
      }
      const time = $(item)
        .closest('div.row')
        .find('h6 span')
        .attr('data-original-title');

      $('#provisioning_template_audit_comment').text(Jed.sprintf(__('Revert to revision from: %s'), time));
    },
  });
}

export function enterFullscreen(element, relativeTo) {
  let $element = $(element);

  if (relativeTo) {
    $element = $(relativeTo).find(element);
  }

  $element.children().removeClass('hidden');
  $element
    .data('origin', $element.parent())
    .data('position', $(window).scrollTop())
    .addClass('fullscreen')
    .appendTo($('.container-pf-nav-pf-vertical'))
    .resize();
  $('.btn-fullscreen').addClass('hidden');
  $('.btn-exit-fullscreen').removeClass('hidden');

  $('#content').addClass('hidden');
  $(document).on('keyup', (e) => {
    if (e.keyCode === 27) {
      // esc
      exitFullscreen();
    }
  });
  Editor.resize(true);
}

export function exitFullscreen() {
  const element = $('.fullscreen');

  $('#content').removeClass('hidden');
  element
    .removeClass('fullscreen')
    .prependTo(element.data('origin'))
    .resize();

  $('.btn-exit-fullscreen').addClass('hidden');
  $('.btn-fullscreen').removeClass('hidden');
  $(window).scrollTop(element.data('position'));
  Editor.resize(true);
}

export function renderTemplatesDiff(containerDiv) {
  const containerEle = $(containerDiv);
  const editorSource = $(containerEle.find('.editor_source'));
  if (editorSource.length) {
    const editorId = `editor-${Math.random()}`;
    const editorContainer = editorSource.parent('.editor-container');
    editorContainer.append(`<div id="${editorId}" class="editor"></div>`);
    editorSource.hide();

    const editor = ace.edit(editorId);
    editor.$blockScrolling = Infinity;
    editor.setShowPrintMargin(false);
    editor.renderer.setShowGutter(false);
    setMode('ace/mode/ruby', editor);
    $(document).on('resize', editorId, () => {
      editor.resize();
    });
    setDiffMode(
      editorSource,
      editorContainer.siblings('#old').val(),
      editorContainer.siblings('#new').val(),
      editor,
    );
    editor.setOptions({ autoScrollEditorIntoView: true, maxLines: 10 });
  }
}
