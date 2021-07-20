import { capitalize } from '../../../common/helpers';
import { translate as __, sprintf } from '../../../common/I18n';
import { put } from '../../../redux/API';
import { POWER_REQURST_KEY } from './constant';

export const changeHostPower = (state, hostID) =>
  put({
    key: POWER_REQURST_KEY,
    params: { power_action: state },
    url: `/api/hosts/${hostID}/power`,
    errorToast: err => __(`an error occured - ${err}`),
    successToast: () =>
      sprintf('Power has been set to "%s" successfully', state),
    updateData: (prevState, { power }) => {
      if (power)
        return {
          ...prevState,
          state,
          title: capitalize(state),
        };
      return { ...prevState };
    },
  });
