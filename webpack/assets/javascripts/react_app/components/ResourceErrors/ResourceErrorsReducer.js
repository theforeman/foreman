import Immutable from 'seamless-immutable';

import {
  RESOURCE_ERRORS_RESOLVE,
  RESOURCE_ERRORS_RERUN,
} from './ResourceErrorsConstants';

export const initialState = Immutable({
  resolved: false,
  rerunAt: null,
  resources: {},
});

const resourceErrors = (state = initialState, action) => {
  const { payload } = action;

  switch (action.type) {
    case RESOURCE_ERRORS_RESOLVE: {
      return state.merge({
        resolved: true,
        resources: payload.resourceErrors,
      });
    }
    case RESOURCE_ERRORS_RERUN: {
      return state.merge({
        rerunAt: payload.rerunAt,
      });
    }
    default: {
      return state;
    }
  }
};

export default resourceErrors;
