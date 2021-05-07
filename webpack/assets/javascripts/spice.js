/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-attr */
/* eslint-disable jquery/no-class */
/* eslint-disable jquery/no-text */

import $ from 'jquery';
import {
  SpiceMainConn,
  sendCtrlAltDel as _sendCtrlAltDel,
} from '@spice-project/spice-html5';
import { sprintf, translate as __ } from './react_app/common/I18n';

let sc = null;

export function startSpice() {
  const scheme = $('#spice-area').data('encrypt') ? 'wss' : 'ws';
  const host = window.location.hostname;
  const port = $('#spice-area').data('port');
  const password = $('#spice-area').data('password');

  if (!host || !port) {
    // eslint-disable-next-line no-console
    console.log(__('must set host and port'));
    return;
  }

  const uri = `${scheme}://${host}:${port}`;

  try {
    sc = new SpiceMainConn({
      uri,
      screen_id: 'spice-screen',
      password,
      onerror: spiceError,
      onsuccess: spiceSuccess,
    });
  } catch (e) {
    alert(e.toString());
    disconnect();
  }
}

export function disconnect() {
  if (sc) {
    sc.stop();
  }
}

function spiceError(e) {
  $('#spice-status').text(e);
  $('#spice-status')
    .removeClass('label-success')
    .addClass('label-danger');
  disconnect();
}

function spiceSuccess(m) {
  $('#spice-status').text(
    sprintf(__('Connected to: %s'), $('#spice-status').attr('data-host'))
  );
  $('#spice-status').addClass('label-success');
}

export function sendCtrlAltDel() {
  window.sc = sc;
  _sendCtrlAltDel();
  window.sc = undefined;
}
