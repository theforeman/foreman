import { STATUS_REQUEST, STATUS_SUCCESS, STATUS_FAILURE } from '../../consts';
import { ajaxRequestAction } from '../common';

export const getStatus = ({ id, type }, url) => dispatch =>
  ajaxRequestAction({
    dispatch,
    requestAction: STATUS_REQUEST,
    successAction: STATUS_SUCCESS,
    failedAction: STATUS_FAILURE,
    url,
    item: { id, type },
  });
