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

export default (state = initialState, { type, payload, response }) => {
  const { REQUEST, SUCCESS, FAILURE } = actionTypeGenerator(FACT_CHART);
  switch (type) {
    case REQUEST:
      return state.set('loaderStatus', 'PENDING');
    case SUCCESS:
      return state
        .set('chartData', response.values)
        .set('loaderStatus', 'RESOLVED');
    case FAILURE:
      return state.set('loaderStatus', 'ERROR');
    case FACT_CHART_MODAL_OPEN:
      return state
        .set('title', payload.title)
        .set('modalToDisplay', { [payload.id]: true });
    case FACT_CHART_MODAL_CLOSE:
      return state
        .set('modalToDisplay', {})
        .set('loaderStatus', '')
        .set('chartData', []);
    default:
      return state;
  }
};
