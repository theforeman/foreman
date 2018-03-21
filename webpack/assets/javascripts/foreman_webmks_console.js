/* eslint-disable no-console, max-len, no-undef */
import $ from 'jquery';
import { showSpinner, hideSpinner, iconText } from './foreman_tools';

require('jquery-ui/ui/widgets/dialog');

let wmks;

export function initConsole() {
  wmks = WMKS.createWMKS('wmksContainer', {})
    .register(WMKS.CONST.Events.CONNECTION_STATE_CHANGE, (event, data) => {
      switch (data.state) {
        case WMKS.CONST.ConnectionState.CONNECTING:
          console.log('wmks: connection state change: connecting');
          showSpinner();
          $('#wmksStatus').show();
          $('#wmksError').hide();
          $('#sendCtrlAltDelButton').prop('disabled', 'disabled');
          $('#enterFullScreenButton').prop('disabled', 'disabled');
          break;
        case WMKS.CONST.ConnectionState.CONNECTED:
          console.log('wmks: connection state change: connected');
          hideSpinner();
          $('#wmksContainer').fadeIn();
          $('#wmksStatus').hide();
          $('#wmksError').hide();
          $('#sendCtrlAltDelButton').removeAttr('disabled');
          $('#enterFullScreenButton').removeAttr('disabled');
          break;
        case WMKS.CONST.ConnectionState.DISCONNECTED:
          console.log('wmks: connection state change: disconnected');
          hideSpinner();
          $('#wmksContainer').hide();
          $('#wmksStatus').hide();
          $('#sendCtrlAltDelButton').prop('disabled', 'disabled');
          $('#enterFullScreenButton').prop('disabled', 'disabled');
          $('#wmksError').html(`<div class="alert alert-danger alert-dismissable">
            ${iconText('error-circle-o', '', 'pficon')}
            <button type="button" class="close" data-dismiss="alert" aria-hidden="true">&times;</button>
            ${__('The console connection was lost.')}
            ${__('Please check if you can access the hypervisor host via https by clicking the link above.')}
            </div>`).fadeIn();
          break;
        default:
      }
    });

  wmks.connect($('#wmksContainer').data('url'));

  $(document).on('click', '#sendCtrlAltDelButton', () => {
    console.log('wmks: sending ctrl + alt + delete');
    wmks.sendKeyCodes([17, 18, 46]); // Ctrl + Alt + Delete
  });

  $(document).on('click', '#enterFullScreenButton', () => {
    console.log('wmks: entering full screen');
    wmks.enterFullScreen();
  });
}
