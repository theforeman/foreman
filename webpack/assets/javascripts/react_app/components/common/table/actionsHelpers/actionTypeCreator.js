const createTableActionTypes = controller => ({
  REQUEST: `${controller.toUpperCase()}_TABLE_REQUEST`,
  SUCCESS: `${controller.toUpperCase()}_TABLE_SUCCESS`,
  FAILURE: `${controller.toUpperCase()}_TABLE_FAILURE`,
});

export default createTableActionTypes;
