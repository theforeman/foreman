import forceSingleton from '../../../common/forceSingleton';

const coreTableRowActionsRegistry = forceSingleton(
  'coreTableRowActionsRegistry',
  () => ({})
);

// Unlike the column registry which is collecting objects that describe table columns,
// here we collect an object containing a single getActions funtion, which returns an array of kebab action items.
export const registerGetActions = ({
  pluginName,
  getActionsFunc,
  tableName = 'hosts',
}) => {
  if (!coreTableRowActionsRegistry[pluginName])
    coreTableRowActionsRegistry[pluginName] = {};
  coreTableRowActionsRegistry[pluginName][tableName] = {
    getActions: getActionsFunc,
  };
};

export const registeredTableRowActions = ({ tableName = 'hosts' }) => {
  const result = {};
  Object.keys(coreTableRowActionsRegistry).forEach(pluginName => {
    if (coreTableRowActionsRegistry[pluginName]?.[tableName]) {
      result[pluginName] = coreTableRowActionsRegistry[pluginName][tableName];
    }
  });
  // { katello: { getActions: [Function: getActions] } }
  return result;
};

export const getActions = (hostDetailsResult, { tableName = 'hosts' } = {}) => {
  const result = [];
  const allGetActionsFuncs = registeredTableRowActions({ tableName });
  Object.values(allGetActionsFuncs).forEach(
    ({ getActions: getActionsFunc }) => {
      if (typeof getActionsFunc !== 'function') return;
      result.push(...getActionsFunc(hostDetailsResult));
    }
  );
  return result;
};

export default getActions;
