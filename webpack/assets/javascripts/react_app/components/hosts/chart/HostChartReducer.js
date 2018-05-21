import Immutable from 'seamless-immutable';
import { TIMESERIES_REQUEST, TIMESERIES_FAILURE, TIMESERIES_SUCCESS } from './HostChartConsts';
import { STATUS } from '../../../constants';

const hostChartReducer = (state = Immutable({}), action) => {
  const { payload } = action;
  switch (action.type) {
    case TIMESERIES_REQUEST:
      return state.setIn(['charts', payload.name], {
        error: null,
        results: [],
        status: STATUS.PENDING,
      });
    case TIMESERIES_FAILURE:
      return state.setIn(['charts', payload.item.name], {
        error: payload.error.message,
        results: [],
        status: STATUS.ERROR,
      });
    case TIMESERIES_SUCCESS:
      return state.setIn(['charts', payload.name], {
        error: null,
        results: payload.results,
        status: STATUS.RESOLVED,
      });
    default:
      return state;
  }
};

export default hostChartReducer;
