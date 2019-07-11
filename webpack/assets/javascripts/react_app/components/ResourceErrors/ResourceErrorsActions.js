import {
  RESOURCE_ERRORS_RESOLVE,
} from './ResourceErrorsConstants';

export const resolveResourceErrors = resourceErrors => dispatch =>
  dispatch({
    type: RESOURCE_ERRORS_RESOLVE,
    payload: { resourceErrors },
  });
