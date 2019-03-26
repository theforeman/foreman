import Immutable from 'seamless-immutable';

import {
  TEMPLATE_GENERATE_REQUEST,
  TEMPLATE_GENERATE_POLLING,
  TEMPLATE_GENERATE_SUCCESS,
  TEMPLATE_GENERATE_FAILURE,
} from './TemplateGeneratorConstants';

const initialState = Immutable({
  scheduleInProgress: false,
  polling: false,
  dataUrl: null,
});

export default (state = initialState, { type, payload }) => {
  switch (type) {
    case TEMPLATE_GENERATE_REQUEST:
      return state.set('scheduleInProgress', true);
    case TEMPLATE_GENERATE_POLLING:
      return state.merge({
        scheduleInProgress: false,
        dataUrl: payload.url,
        polling: true,
      });
    case TEMPLATE_GENERATE_FAILURE:
      return state.merge({
        scheduleInProgress: false,
        polling: false,
        generatingError: payload.error.message,
        generatingErrorMessages: payload.messages,
      });
    case TEMPLATE_GENERATE_SUCCESS:
      return state.merge({
        scheduleInProgress: false,
        polling: false,
      });
    default:
      return state;
  }
};
