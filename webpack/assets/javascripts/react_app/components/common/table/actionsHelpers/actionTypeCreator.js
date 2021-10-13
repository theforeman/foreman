const createTableActionTypes = (tableID) => ({
  REQUEST: `${tableID.toUpperCase()}_REQUEST`,
  SUCCESS: `${tableID.toUpperCase()}_SUCCESS`,
  FAILURE: `${tableID.toUpperCase()}_FAILURE`,
});

export default createTableActionTypes;
