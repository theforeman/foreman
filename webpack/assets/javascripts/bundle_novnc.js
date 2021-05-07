/* eslint-disable jquery/no-data */
/* eslint-disable jquery/no-attr */

import RFB from '@novnc/novnc/core/rfb';
import $ from 'jquery';
import { sprintf, translate as __ } from './react_app/common/I18n';

let rfb;
const StatusLevelLookup = {
  failed: 'danger',
  fatal: 'danger',
  normal: 'success',
  disconnected: 'default',
};

function sendCtrlAltDel() {
  rfb.sendCtrlAltDel();
  return false;
}

function showStatus(state, message) {
  const level = StatusLevelLookup[state] || 'warning';
  const status = $('#noVNC_status');
  const ctrlAltDeleteButton = $('#ctrlAltDelButton');

  ctrlAltDeleteButton.prop('disabled', state !== 'normal');

  if (typeof message !== 'undefined') {
    status.attr('class', `col-md-12 label label-${level}`);
    status.html(message);
  }
}

function securityFailed(e) {
  let msg = '';
  if ('reason' in e.detail) {
    msg = sprintf(
      __('New connection has been rejected with reason: %'),
      e.detail.reason
    );
  } else {
    msg = __('New connection has been rejected');
  }
  showStatus('fatal', msg);
}

function disconnectFinished() {
  showStatus('failed', __('Disconnected'));
}

function connectFinished() {
  showStatus('normal', __('Connected'));
}

function onClose(e) {
  if (e.code === 1006) {
    showStatus(
      'failed',
      __(
        'The connection was closed by the browser. please verify that the certificate authority is valid'
      )
    );
  }
}
$(document).on('ContentLoad', () => {
  const vncScreen = $('#noVNC_screen');

  if (vncScreen.length) {
    $('#sendCtrlAltDelButton').on('click', sendCtrlAltDel);
    const url = $('#vnc').data('uri');
    const password = $('#vnc').data('password');
    const tokenProtocol = $('#vnc').data('token-protocol');
    const plainProtocol = $('#vnc').data('plain-protocol');
    const options = {};
    if (password) {
      options.credentials = { password };
    }
    if (tokenProtocol || plainProtocol) {
      options.wsProtocols = [tokenProtocol, plainProtocol].filter(String);
    }
    rfb = new RFB(vncScreen.get(0), url, options);
    rfb._sock.on('close', onClose);
    rfb.addEventListener('connect', connectFinished);
    rfb.addEventListener('disconnect', disconnectFinished);
    rfb.addEventListener('securityfailure', securityFailed);

    showStatus('disconnected', __('Loading...'));
  }
});
