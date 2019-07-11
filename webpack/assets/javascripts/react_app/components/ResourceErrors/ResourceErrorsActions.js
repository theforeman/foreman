import {
  RESOURCE_ERRORS_RESOLVE,
  RESOURCE_ERRORS_RERUN,
} from './ResourceErrorsConstants';

export const resolveResourceErrors = resourceErrors => ({
  type: RESOURCE_ERRORS_RESOLVE,
  payload: { resourceErrors },
});

export const rerunResourceErrors = rerunAt => ({
  type: RESOURCE_ERRORS_RERUN,
  payload: { rerunAt },
});
