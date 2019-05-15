const actions = ['REQUEST', 'SUCCESS', 'FAILURE'];

/**
 * Auto generates api consts for redux for given key
 * @param {String} key - the unique name of the component
 * @param {Object} actionTypes - custom types to use instead of the auto generated ones
 */
export const actionTypeGenerator = (key, actionTypes = {}) => {
  actions.forEach(type => {
    actionTypes[type] = actionTypes[type] || `${key}_${type}`;
  });
  return actionTypes;
};
