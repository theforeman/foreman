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
  const uri = $('#spice-area').data('uri');
  const password = $('#spice-area').data('password');

  if (!uri) {
    // eslint-disable-next-line no-console
    console.log(__('Spice connection must set uri'));
    return;
  }

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
