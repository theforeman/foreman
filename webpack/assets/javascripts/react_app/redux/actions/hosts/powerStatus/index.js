import { HOST_POWER_STATUS } from '../../../consts';
import { API_OPERATIONS } from '../../../API';

export const getHostPowerState = ({ id, url }) => ({
  type: API_OPERATIONS.GET,
  key: HOST_POWER_STATUS,
  url,
  payload: { id },
});
