import Immutable from 'seamless-immutable';
import {
  HOST_POWER_STATUS_REQUEST,
  HOST_POWER_STATUS_SUCCESS,
  HOST_POWER_STATUS_FAILURE,
} from '../../../consts';

const initialState = Immutable({});

export default (state = initialState, { type, payload, response }) => {
  switch (type) {
    case HOST_POWER_STATUS_REQUEST:
      return state.set(payload.id, payload);
    case HOST_POWER_STATUS_SUCCESS:
      return state.set(payload.id, response);
    case HOST_POWER_STATUS_FAILURE: {
      const {
        message: errorMessage,
        response: { data },
      } = response;

      return state.set(data.id, { error: errorMessage, ...data });
    }
    default:
      return state;
  }
};
