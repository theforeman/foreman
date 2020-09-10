import Immutable from 'seamless-immutable';
import {
  FACT_CHART_MODAL_CLOSE,
  FACT_CHART_MODAL_OPEN,
} from './FactChartConstants';

const initialState = Immutable({
  modalToDisplay: {},
});

// should be removed when the modals infrastructure will get merged.
export default (state = initialState, { type, payload }) => {
  switch (type) {
    case FACT_CHART_MODAL_OPEN:
      return state
        .set('title', payload.title)
        .set('modalToDisplay', { [payload.id]: true });
    case FACT_CHART_MODAL_CLOSE:
      return state.set('modalToDisplay', {});
    default:
      return state;
  }
};
