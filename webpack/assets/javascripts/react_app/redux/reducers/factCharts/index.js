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
});

export default (state = initialState, action) => {
  switch (action.type) {
    case FACT_CHART_DATA_REQUEST:
      return state.set('loaderStatus', 'PENDING');
    case FACT_CHART_DATA_SUCCESS:
      return state
        .set('chartData', action.payload.values)
        .set('loaderStatus', 'RESOLVED');
    case FACT_CHART_DATA_FAILURE:
      return state.set('loaderStatus', 'ERROR');
    case OPEN_FACT_CHART_MODAL:
      return state
        .set('title', action.payload.title)
        .set('modalToDisplay', { [action.payload.id]: true });
    case CLOSE_FACT_CHART_MODAL:
      return state
        .set('modalToDisplay', {})
        .set('loaderStatus', '')
        .set('chartData', []);
    default:
      return state;
  }
};
