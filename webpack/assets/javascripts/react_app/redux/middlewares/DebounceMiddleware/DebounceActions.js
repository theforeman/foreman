import {
  DEBOUNCE_START,
  DEBOUNCE_CLEAR,
  DEBOUNCE_STOP_INCOMING_ACTION,
} from './DebounceConstants';

export const startDebounce = ({ key, debounceID }) => ({
  type: DEBOUNCE_START,
  payload: {
    key,
    debounceID,
  },
});

export const clearDebounce = key => ({
  type: DEBOUNCE_CLEAR,
  payload: {
    key,
  },
});

export const stopIncomingAction = key => ({
  type: DEBOUNCE_STOP_INCOMING_ACTION,
  payload: {
    key,
  },
});
