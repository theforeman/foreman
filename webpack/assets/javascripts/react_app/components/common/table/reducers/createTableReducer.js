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
});

const createTableReducer = tableID => (state = initState, action) => {
  const { REQUEST, FAILURE, SUCCESS, SET_PAGINATION } = createTableActionTypes(
    tableID
  );
  const {
    type,
    payload: { results, subtotal, page, sort, per_page: perPage, error } = {},
  } = action;
  switch (type) {
    case REQUEST:
      return state.set('status', STATUS.PENDING);
    case SUCCESS:
      return Immutable.merge(state, {
        error: null,
        status: STATUS.RESOLVED,
        results,
        sortBy: sort.by,
        sortOrder: sort.order,
        itemCount: subtotal,
        pagination: {
          page: Number(page),
          perPage: Number(perPage),
        },
      });
    case FAILURE:
      return Immutable.merge(state, {
        error,
        status: STATUS.ERROR,
        results: [],
      });
    case SET_PAGINATION:
      return Immutable.merge(state, {
        pagination: {
          page,
          per_page: perPage,
        },
      });
    default:
      return state;
  }
};

export default createTableReducer;
