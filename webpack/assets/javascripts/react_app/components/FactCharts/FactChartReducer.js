import Immutable from 'seamless-immutable';
import {
  FACT_CHART,
  FACT_CHART_MODAL_CLOSE,
  FACT_CHART_MODAL_OPEN,
} from './FactChartConstants';

import { actionTypeGenerator } from '../../redux/API';

const initialState = Immutable({
  modalToDisplay: {},
  chartData: [],
  loaderStatus: '',
});

export default (state = initialState, action) => {
  const { REQUEST, SUCCESS, FAILURE } = actionTypeGenerator(FACT_CHART);
  switch (action.type) {
    case REQUEST:
      return state.set('loaderStatus', 'PENDING');
    case SUCCESS:
      return state
        .set('chartData', action.payload.values)
        .set('loaderStatus', 'RESOLVED');
    case FAILURE:
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
