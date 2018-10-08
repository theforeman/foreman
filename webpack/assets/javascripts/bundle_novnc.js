import RFB from '@novnc/novnc/core/rfb';

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
    msg = window.Jed.sprintf(__('New connection has been rejected with reason: %'), e.detail.reason);
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

$(document).on('ContentLoad', () => {
  const vncScreen = $('#noVNC_screen');

  if (vncScreen.length) {
    $('#sendCtrlAltDelButton').on('click', sendCtrlAltDel);

    const protocol = $('#vnc').data('encrypt') ? 'wss' : 'ws';
    const host = window.location.hostname;
    const port = $('#vnc').attr('data-port');
    const url = `${protocol}://${host}:${port}`;
    const password = $('#vnc').attr('data-password');

    rfb = new RFB(vncScreen.get(0), url, {
      credentials: {
        password,
      },
    });

    rfb.addEventListener('connect', connectFinished);
    rfb.addEventListener('disconnect', disconnectFinished);
    rfb.addEventListener('securityfailure', securityFailed);

    showStatus('disconnected', __('Loading...'));
  }
});
