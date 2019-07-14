import api from '../../../../API';
import { foremanUrl } from '../../../../../foreman_tools';

import { addToast } from '../../../../redux/actions/toasts';

export const stopImpersonating = (url, history) => dispatch =>
  api
    .delete(url)
    // eslint-disable-next-line promise/prefer-await-to-then
    .then(({ data }) => {
      window.location.href = foremanUrl('/users');

      dispatch(
        addToast({
          type: data.type,
          message: data.message,
        })
      );
    })
    .catch(err => {
      dispatch(
        addToast({
          type: 'error',
          message: 'Failed to stop impersonation',
        })
      );
    });
