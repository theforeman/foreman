import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';
import {
  BULK_UPDATE_PARAMETERS_KEY,
  BULK_UPDATE_PARAMETERS_URL,
  COMMON_PARAMETERS_KEY,
  COMMON_PARAMETERS_URL,
} from './constants';

export const bulkUpdateParameters = (params, handleSuccess, handleError) =>
  APIActions.put({
    key: BULK_UPDATE_PARAMETERS_KEY,
    url: foremanUrl(BULK_UPDATE_PARAMETERS_URL),
    handleSuccess,
    handleError,
    params,
  });

export const fetchCommonParameters = () =>
  APIActions.get({
    key: COMMON_PARAMETERS_KEY,
    url: foremanUrl(COMMON_PARAMETERS_URL),
    params: {
      per_page: 'all',
    },
  });
