import { getChartData } from '../HostChartActions';
import { ajaxRequestAction } from '../../../../redux/actions/common';
import { TIMESERIES_REQUEST, TIMESERIES_SUCCESS, TIMESERIES_FAILURE } from '../HostChartConsts';

jest.mock('../../../../redux/actions/common');

describe('Timeseries chart actions', () => {
  it('should call ajaxRequestAction on getChartData', () => {
    const url = '/runtime/ts';
    const name = 'runtime';
    const dispatch = jest.fn();

    getChartData(url, name)(dispatch);
    expect(ajaxRequestAction).toBeCalledWith({
      dispatch,
      url,
      item: { name },
      requestAction: TIMESERIES_REQUEST,
      successAction: TIMESERIES_SUCCESS,
      failedAction: TIMESERIES_FAILURE,
    });
  });
});
