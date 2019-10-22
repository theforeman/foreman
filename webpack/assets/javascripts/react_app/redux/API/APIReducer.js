/* eslint-disable no-case-declarations, no-console */
import Immutable from 'seamless-immutable';
import { API_OPERATIONS } from './APIConstants';
import {
  startAPIInterval,
  stopAPIInterval,
  unregisteredPollingException,
} from './APIHelpers';

const { START_POLLING, STOP_POLLING } = API_OPERATIONS;
const initialState = Immutable({
  polling: {},
});

export const reducer = (state = initialState, action) => {
  const { type, key, payload: { APIRequest, polling } = {} } = action;
  switch (type) {
    case START_POLLING:
      const pollingID = startAPIInterval(APIRequest, polling);
      return state.setIn(['polling'], {
        ...state.polling,
        [key]: pollingID,
      });
    case STOP_POLLING:
      const pollingProcessID = state.polling[key];
      if (!pollingProcessID) {
        console.error(unregisteredPollingException(key));
        return state;
      }
      stopAPIInterval(pollingProcessID);
      return state.setIn(['polling'], state.polling.without(key));
    default:
      return state;
  }
};

export const reducers = { API_operations: reducer };

export default reducer;
