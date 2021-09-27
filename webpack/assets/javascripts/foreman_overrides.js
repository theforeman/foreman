import $ from 'jquery';
import store from './react_app/redux';
import { translate as __ } from './react_app/common/I18n';

import { openConfirmModal } from './react_app/components/ConfirmModal';

$(document).on('ContentLoad', () => {
  if (!$.rails) return;
  // override the jQuery UJS $.rails.allowAction
  $.rails.allowAction = element => {
    const message = element.data('confirm');
    const isWarning = element.data('method') === 'delete';
    if (!message) return true;

    if ($.rails.fire(element, 'confirm')) {
      store.dispatch(
        openConfirmModal({
          title: __('Confirm'),
          message,
          isWarning,
          onConfirm: () => {
            const oldAllowAction = $.rails.allowAction;
            $.rails.allowAction = () => true;
            element[0].click();
            $.rails.allowAction = oldAllowAction;
          },
        })
      );
    }
    return false;
  };
});
