import { HOST_POWER_STATUS } from '../../../consts';
import { get } from '../../../API';

export const getHostPowerState = ({ id, url }) =>
  get({
    key: HOST_POWER_STATUS,
    url,
    payload: { id },
  });
