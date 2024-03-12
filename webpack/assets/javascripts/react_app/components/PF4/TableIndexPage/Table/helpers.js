export const getPageStats = ({ total, page, perPage }) => {
  // logic adapted from patternfly so that we can know the number of items per page
  const lastPage = Math.ceil(total / perPage) ?? 0;
  const firstIndex = total <= 0 ? 0 : (page - 1) * perPage + 1;
  let lastIndex;
  if (total <= 0) {
    lastIndex = 0;
  } else {
    lastIndex = page === lastPage ? total : page * perPage;
  }
  let pageRowCount = lastIndex - firstIndex + 1;
  if (total <= 0) pageRowCount = 0;
  return {
    firstIndex,
    lastIndex,
    pageRowCount,
    lastPage,
  };
};

/**
 * Assembles column data into various forms needed
 * @param {Object} columns - Object with column sort params as keys and column objects as values. Column objects must have a title key
 * @returns {Array} - an array of column sort params, sorted by weight, and a map of keys to column names
 */
export const getColumnHelpers = columns => {
  const columnNamesKeys = Object.keys(columns);
  const keysToColumnNames = {};
  columnNamesKeys.forEach(key => {
    keysToColumnNames[key] = columns[key].title;
  });
  columnNamesKeys.sort((a, b) => {
    const columnBWeight = columns[b]?.weight;
    const columnAWeight = columns[a]?.weight;
    if (columnBWeight === undefined) {
      return -1;
    }
    if (columnAWeight === undefined) {
      return 1;
    }
    return columnAWeight - columnBWeight;
  });
  return [columnNamesKeys, keysToColumnNames];
};

export const DEFAULT_USER_COLUMNS = [
  'name',
  'hostgroup',
  'os_title',
  'owner',
  'last_report',
];

/**
 * Filters column data by user preferences
 * @param {Array} columnNames - Array of column names from user preferences
 * @param {Object} allColumnData - Object with column sort params as keys and column objects as values
 * @returns {Object} - The filtered object with column sort params as keys and column objects as values
 */
export const filterColumnDataByUserPreferences = (
  isLoading,
  columnNames = isLoading ? [] : DEFAULT_USER_COLUMNS,
  allColumnData
) => {
  const filteredColumns = {};
  columnNames.forEach(key => {
    if (allColumnData[key]) {
      filteredColumns[key] = allColumnData[key];
    }
  });
  return filteredColumns;
};
