import forceSingleton from '../../../common/forceSingleton';
import generalColumns from './generalColumns';
import networkColumns from './networkColumns';
import reportedDataColumns from './reportedDataColumns';

const coreColumnRegistry = forceSingleton('coreColumnRegistry', () => ({}));

export const registerColumns = columns => {
  columns.forEach(column => {
    coreColumnRegistry[column.columnName] = column;
  });
};

registerColumns(generalColumns);
registerColumns(networkColumns);
registerColumns(reportedDataColumns);

export const RegisteredColumns = ({ tableName = 'hosts' }) => {
  const result = {};
  Object.keys(coreColumnRegistry).forEach(column => {
    if (coreColumnRegistry[column]?.tableName === tableName) {
      result[column] = coreColumnRegistry[column];
    }
  });
  return result;
};

export default RegisteredColumns;
