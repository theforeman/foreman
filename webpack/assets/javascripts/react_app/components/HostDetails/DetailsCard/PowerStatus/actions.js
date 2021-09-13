import { translate as __, sprintf } from '../../../../common/I18n';
import { put } from '../../../../redux/API';
import { POWER_REQURST_KEY, SUPPORTED_POWER_STATES } from './constants';

export const changeHostPower = (state, hostID) =>
  put({
    key: POWER_REQURST_KEY,
    params: { power_action: state },
    url: `/api/hosts/${hostID}/power`,
    errorToast: err => sprintf(__('an error occurred: %s'), err),
    successToast: () =>
      sprintf(
        __('Power has been set to "%s" successfully'),
        SUPPORTED_POWER_STATES[state]
      ),
    updateData: (prevState, { power }) => {
      if (power)
        return {
          ...prevState,
          state,
          title: SUPPORTED_POWER_STATES[state],
        };
      return prevState;
    },
  });
