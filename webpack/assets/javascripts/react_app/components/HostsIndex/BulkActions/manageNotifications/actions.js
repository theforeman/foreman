import { APIActions } from '../../../../redux/API';
import { foremanUrl } from '../../../../common/helpers';
import {
  BULK_MANAGE_NOTIFICATIONS_KEY,
  BULK_MANAGE_NOTIFICATIONS_URL,
} from './constants';

export const bulkManageNotifications = (params, handleSuccess, handleError) =>
  APIActions.put({
    key: BULK_MANAGE_NOTIFICATIONS_KEY,
    url: foremanUrl(BULK_MANAGE_NOTIFICATIONS_URL),
    handleSuccess,
    handleError,
    params,
  });
