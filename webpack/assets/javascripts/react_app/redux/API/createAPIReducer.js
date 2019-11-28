import Immutable from 'seamless-immutable';
import { STATUS } from '../../constants';
import { actionTypeGenerator } from './APIActionTypeGenerator';
import { noop } from '../../common/helpers';

const initState = Immutable({
  error: null,
  status: STATUS.PENDING,
});

const getModifiedState = (state, newState, payload, managedByID) => {
  const { id } = payload;
  const nextState = managedByID
    ? state.set(id, { ...state[id], ...newState })
    : state.merge(newState);

  return nextState;
};

const handleRequest = (state, payload, managedByID) => {
  const newState = {
    error: null,
    status: STATUS.PENDING,
  };

  return getModifiedState(state, newState, payload, managedByID);
};

const handleSuccess = (state, payload, managedByID) => {
  const newState = {
    error: null,
    status: STATUS.RESOLVED,
    ...payload,
  };

  return getModifiedState(state, newState, payload, managedByID);
};

const handleFailure = (state, payload, managedByID) => {
  const newState = {
    error: payload.error,
    status: STATUS.ERROR,
  };

  return getModifiedState(state, newState, payload, managedByID);
};

const createAPIReducer = ({
  key,
  initialState: theirState,
  managedByID = false,
  onRequest = noop,
  onSuccess = noop,
  onFailure = noop,
}) => (state = theirState || initState, action) => {
  if (key === undefined) throw new Error('key is required');

  const { REQUEST, FAILURE, SUCCESS } = actionTypeGenerator(key);
  const { type, payload } = action;

  switch (type) {
    case REQUEST:
      return (
        onRequest(state, payload) || handleRequest(state, payload, managedByID)
      );
    case SUCCESS:
      return (
        onSuccess(state, payload) || handleSuccess(state, payload, managedByID)
      );
    case FAILURE:
      return (
        onFailure(state, payload) || handleFailure(state, payload, managedByID)
      );
    default:
      return state;
  }
};

export default createAPIReducer;
