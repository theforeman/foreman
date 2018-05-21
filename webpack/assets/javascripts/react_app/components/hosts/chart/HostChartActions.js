import { ajaxRequestAction } from '../../../redux/actions/common';
import * as tsConsts from './HostChartConsts';

export const getChartData = (url, name) => (dispatch) => {
  ajaxRequestAction({
    dispatch,
    requestAction: tsConsts.TIMESERIES_REQUEST,
    successAction: tsConsts.TIMESERIES_SUCCESS,
    failedAction: tsConsts.TIMESERIES_FAILURE,
    url,
    item: { name },
  });
};
