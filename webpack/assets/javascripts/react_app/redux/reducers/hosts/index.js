import {
  HOST_POWER_STATUS_REQUEST,
  HOST_POWER_STATUS_SUCCESS,
  HOST_POWER_STATUS_FAILURE
} from '../../consts';
import Immutable from 'seamless-immutable';

const initialState = Immutable({
  powerStatus: Immutable({})
});

export default (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case HOST_POWER_STATUS_REQUEST:
    case HOST_POWER_STATUS_SUCCESS:
      return state.setIn(
        ['powerStatus', payload.id],
        payload
      );
    case HOST_POWER_STATUS_FAILURE:
      return state.setIn(
        ['powerStatus', payload.id],
        { error: payload.error }
      );
    default:
      return state;
  }
};
