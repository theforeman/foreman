import createTableActionTypes from '../common/table/actionsHelpers/actionTypeCreator';

export const MODELS_TABLE_CONTROLLER = 'models';
export const MODELS_TABLE_ACTION_TYPES = createTableActionTypes(
  MODELS_TABLE_CONTROLLER
);
