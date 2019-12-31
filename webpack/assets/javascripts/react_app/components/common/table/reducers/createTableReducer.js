import Immutable from 'seamless-immutable';
import { STATUS } from '../../../../constants';
import createTableActionTypes from '../actionsHelpers/actionTypeCreator';

const initState = Immutable({
  error: null,
  sortBy: '',
  sortOrder: '',
  results: [],
  status: STATUS.PENDING,
});

const createTableReducer = tableID => (
  state = initState,
  { type, payload, response }
) => {
  const { REQUEST, FAILURE, SUCCESS } = createTableActionTypes(tableID);

  switch (type) {
    case REQUEST:
      return state.set('status', STATUS.PENDING);
    case SUCCESS:
      return Immutable.merge(state, {
        error: null,
        status: STATUS.RESOLVED,
        results: response.results,
        sortBy: response.sort.by,
        sortOrder: response.sort.order,
      });
    case FAILURE:
      return Immutable.merge(state, {
        error: response,
        status: STATUS.ERROR,
        results: [],
      });
    default:
      return state;
  }
};

export default createTableReducer;
