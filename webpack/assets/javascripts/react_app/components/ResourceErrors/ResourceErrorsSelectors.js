import { deepPropsToCamelCase } from '../../common/helpers';

const resourceErrorsState = state => state.resourceErrors;

export const selectResourceErrors = state =>
  deepPropsToCamelCase(resourceErrorsState(state).resources);
