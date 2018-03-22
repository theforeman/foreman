import {
  HOST_POWER_STATUS_REQUEST,
  HOST_POWER_STATUS_SUCCESS,
  HOST_POWER_STATUS_FAILURE,
} from '../../../consts';
import { ajaxRequestAction } from '../../common';

export const getHostPowerState = ({ id, url }) => dispatch =>
  ajaxRequestAction({
    dispatch,
    requestAction: HOST_POWER_STATUS_REQUEST,
    successAction: HOST_POWER_STATUS_SUCCESS,
    failedAction: HOST_POWER_STATUS_FAILURE,
    url,
    item: { id },
  });
