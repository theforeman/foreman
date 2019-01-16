import Immutable from 'seamless-immutable';
import {
  FACT_CHART_REQUEST,
  FACT_CHART_SUCCESS,
  FACT_CHART_FAILURE,
  FACT_CHART_MODAL_CLOSE,
  FACT_CHART_MODAL_OPEN,
} from './FactChartConstants';

const initialState = Immutable({
  modalToDisplay: {},
  chartData: [],
  loaderStatus: '',
});

export default (state = initialState, action) => {
  switch (action.type) {
    case FACT_CHART_REQUEST:
      return state.set('loaderStatus', 'PENDING');
    case FACT_CHART_SUCCESS:
      return state
        .set('chartData', action.payload.values)
        .set('loaderStatus', 'RESOLVED');
    case FACT_CHART_FAILURE:
      return state.set('loaderStatus', 'ERROR');
    case FACT_CHART_MODAL_OPEN:
      return state
        .set('title', action.payload.title)
        .set('modalToDisplay', { [action.payload.id]: true });
    case FACT_CHART_MODAL_CLOSE:
      return state
        .set('modalToDisplay', {})
        .set('loaderStatus', '')
        .set('chartData', []);
    default:
      return state;
  }
};
