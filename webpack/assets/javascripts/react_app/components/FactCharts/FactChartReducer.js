import Immutable from 'seamless-immutable';
import {
  FACT_CHART,
  FACT_CHART_MODAL_CLOSE,
  FACT_CHART_MODAL_OPEN,
} from './FactChartConstants';

import { createAPIReducer } from '../../redux/API';

const initialState = Immutable({
  modalToDisplay: {},
  title: '',
});

const APIstate = Immutable({
  chartData: [],
});

const onSuccess = (state, payload) =>
  state.set('chartData', payload.values).set('status', 'RESOLVED');

export const apiReducer = createAPIReducer({
  key: FACT_CHART,
  initialState: APIstate,
  onSuccess,
});

export default (state = initialState, action) => {
  switch (action.type) {
    case FACT_CHART_MODAL_OPEN:
      return state
        .set('title', action.payload.title)
        .set('modalToDisplay', { [action.payload.id]: true });
    case FACT_CHART_MODAL_CLOSE:
      return state.set('modalToDisplay', {});
    default:
      return state;
  }
};
