import Immutable from 'seamless-immutable';
import {
  HOST_POWER_STATUS_REQUEST,
  HOST_POWER_STATUS_SUCCESS,
  HOST_POWER_STATUS_FAILURE,
} from '../../../consts';

const initialState = Immutable({});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case HOST_POWER_STATUS_REQUEST:
    case HOST_POWER_STATUS_SUCCESS:
      return state.set(payload.id, payload);
    case HOST_POWER_STATUS_FAILURE:
      return state.set(payload.item.id, { error: payload.error });
    default:
      return state;
  }
};
