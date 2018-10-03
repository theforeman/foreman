import Immutable from 'seamless-immutable';
import {
  FACT_CHART_DATA_REQUEST,
  FACT_CHART_DATA_SUCCESS,
  FACT_CHART_DATA_FAILURE,
  CLOSE_FACT_CHART_MODAL,
  OPEN_FACT_CHART_MODAL,
} from '../../consts';

const initialState = Immutable({
  modalToDisplay: {},
  chartData: [],
  loaderStatus: '',
  hostsCount: null,
});

let hostsCount = 0;

export default (state = initialState, action) => {
  switch (action.type) {
    case FACT_CHART_DATA_REQUEST:
      return state.set('loaderStatus', 'PENDING');
    case FACT_CHART_DATA_SUCCESS:
      action.payload.values.forEach(val => {
        hostsCount += val[1];
      });
      return state
        .set('chartData', action.payload.values)
        .set('hostsCount', hostsCount)
        .set('loaderStatus', 'RESOLVED');
    case FACT_CHART_DATA_FAILURE:
      return state.set('loaderStatus', 'ERROR');
    case OPEN_FACT_CHART_MODAL:
      return state
        .set('title', action.payload.title)
        .set('modalToDisplay', { [action.payload.id]: true });
    case CLOSE_FACT_CHART_MODAL:
      hostsCount = 0;
      return state
        .set('modalToDisplay', {})
        .set('loaderStatus', '')
        .set('hostsCount', null)
        .set('chartData', []);
    default:
      return state;
  }
};
