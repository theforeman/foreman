const createTableActionTypes = tableID => ({
  REQUEST: `${tableID.toUpperCase()}_REQUEST`,
  SUCCESS: `${tableID.toUpperCase()}_SUCCESS`,
  FAILURE: `${tableID.toUpperCase()}_FAILURE`,
  SET_PAGINATION: `${tableID.toUpperCase()}_SET_PAGINATION`,
});

export default createTableActionTypes;
