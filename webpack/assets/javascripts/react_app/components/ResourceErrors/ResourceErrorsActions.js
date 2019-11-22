import {
  RESOURCE_ERRORS_RESOLVE,
  RESOURCE_ERRORS_RERUN,
} from './ResourceErrorsConstants';

export const resolveResourceErrors = resourceErrors => dispatch =>
  dispatch({
    type: RESOURCE_ERRORS_RESOLVE,
    payload: { resourceErrors },
  });

export const rerunResourceErrors = rerunAt => dispatch =>
  dispatch({
    type: RESOURCE_ERRORS_RERUN,
    payload: { rerunAt },
  });
