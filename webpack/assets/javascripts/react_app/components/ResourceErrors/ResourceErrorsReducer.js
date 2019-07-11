import Immutable from 'seamless-immutable';
import { deepPropsToCamelCase } from '../../common/helpers';

import {
  RESOURCE_ERRORS_RESOLVE,
} from './ResourceErrorsConstants';

export const initialState = Immutable({
  resolved: false,
  resources: {},
});

const resourceErrors = (state = initialState, action) => {
  const { payload } = action;

  switch(action.type) {
    case RESOURCE_ERRORS_RESOLVE: {
      return state.merge({
        resolved: true,
        resources: payload.resourceErrors,
      });
    }
    default: {
      return state;
    }
  };
};

export default resourceErrors;
