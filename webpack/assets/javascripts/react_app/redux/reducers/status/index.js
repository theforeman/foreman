import Immutable from 'seamless-immutable';
import { STATUS_REQUEST, STATUS_SUCCESS, STATUS_FAILURE } from '../../consts';

const initialState = Immutable({});

export default (state = initialState, action) => {
  const { payload, type } = action;

  switch (type) {
    case STATUS_REQUEST:
      return state;
    case STATUS_SUCCESS:
      return state.setIn([payload.type, payload.id], { ...payload });
    case STATUS_FAILURE:
      return state.setIn([payload.item.type, payload.item.id], { error: payload.error });
    default:
      return state;
  }
};
