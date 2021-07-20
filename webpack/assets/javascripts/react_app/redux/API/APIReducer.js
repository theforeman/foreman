import Immutable from 'seamless-immutable';
import { actionTypeGenerator } from './APIActionTypeGenerator';
import { STATUS } from '../../constants';

const initialState = Immutable({});

const apiReducer = (state = initialState, { type, key, payload, response }) => {
  if (key === undefined) return state;

  const { REQUEST, SUCCESS, FAILURE, UPDATE } = actionTypeGenerator(key);
  const { PENDING, RESOLVED, ERROR } = STATUS;

  switch (type) {
    case REQUEST:
      return state.merge({
        [key]: {
          response: null,
          ...state[key],
          payload,
          status: PENDING,
        },
      });
    case SUCCESS:
      return state.merge({
        [key]: {
          payload,
          response,
          status: RESOLVED,
        },
      });
    case FAILURE:
      return state.merge({
        [key]: {
          payload,
          response,
          status: ERROR,
        },
      });
    case UPDATE:
      return state.setIn([key, 'response'], payload);
    default:
      return state;
  }
};

export default apiReducer;
