import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';
import { BULK_POWER_STATE_KEY, BULK_POWER_STATE_URL } from './constants';

export const bulkChangePowerState = (params, handleSuccess, handleError) =>
  APIActions.put({
    key: BULK_POWER_STATE_KEY,
    url: foremanUrl(BULK_POWER_STATE_URL),
    handleSuccess,
    handleError,
    params,
  });
