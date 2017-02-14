import {
  STATISTICS_DATA_REQUEST,
  STATISTICS_DATA_SUCCESS,
  STATISTICS_DATA_FAILURE
} from '../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  charts: []
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case STATISTICS_DATA_REQUEST: return state.set('charts', payload);
    case STATISTICS_DATA_SUCCESS:
      return state.set('charts', state.charts.map(chart => chart.id === payload.id ?
        { ...chart, data: payload.data } :
        chart
      ));
    case STATISTICS_DATA_FAILURE:
      return state.set('charts', state.charts.map(chart => chart.id === payload.id ?
        { ...chart, error: payload.error } :
        chart
      ));
    default: return state;
  }
};
