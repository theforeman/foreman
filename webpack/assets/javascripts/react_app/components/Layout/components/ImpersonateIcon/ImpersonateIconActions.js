import api from '../../../../API';
import { foremanUrl } from '../../../../../foreman_tools';

import { addToast } from '../../../../redux/actions/toasts';

export const stopImpersonating = url => async dispatch => {
  try {
    const { data } = await api.delete(url);
    window.location.href = foremanUrl('/users');
    return dispatch(
      addToast({
        type: data.type,
        message: data.message,
      })
    );
  } catch (error) {
    return dispatch(
      addToast({
        type: 'error',
        message: 'Failed to stop impersonation',
      })
    );
  }
};
