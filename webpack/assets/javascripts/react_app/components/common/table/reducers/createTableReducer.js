import Immutable from 'seamless-immutable';
import { STATUS } from '../../../../constants';
import createTableActionTypes from '../actionsHelpers/actionTypeCreator';

const initState = Immutable({
  error: null,
  sortBy: '',
  sortOrder: '',
  results: [],
  status: STATUS.PENDING,
  pagination: { page: 1, perPage: 20 },
  total: 0,
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
        pagination: { page: response.page, perPage: response.per_page },
        total: response.total,
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
