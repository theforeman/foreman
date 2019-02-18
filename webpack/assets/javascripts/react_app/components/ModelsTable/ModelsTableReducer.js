import Immutable from '@theforeman/vendor/seamless-immutable';
import { STATUS } from '../../constants';
import { MODELS_TABLE_ACTION_TYPES } from './ModelsTableConstants';

const initState = Immutable({
  error: null,
  sortBy: '',
  sortOrder: '',
  results: [],
  status: STATUS.PENDING,
});
export default (state = initState, action) => {
  const { REQUEST, FAILURE, SUCCESS } = MODELS_TABLE_ACTION_TYPES;
  switch (action.type) {
    case REQUEST:
      return state.set('status', STATUS.PENDING);
    case SUCCESS:
      return Immutable.merge(state, {
        error: null,
        status: STATUS.RESOLVED,
        results: action.payload.results,
        sortBy: action.payload.sort.by,
        sortOrder: action.payload.sort.order,
      });
    case FAILURE:
      return Immutable.merge(state, {
        error: action.payload.error,
        status: STATUS.ERROR,
        results: [],
      });
    default:
      return state;
  }
};
