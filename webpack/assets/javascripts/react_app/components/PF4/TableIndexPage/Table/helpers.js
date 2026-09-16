import { checkColumnRelevancy } from '../../../ColumnSelector/helpers';

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
 * Accessible string label for a column. Never returns a React node — HTML
 * attributes like data-label stringify objects as "[object Object]".
 * @param {Object} column
 * @param {string} fallbackKey
 * @returns {string}
 */
export const getColumnLabel = (column, fallbackKey) => {
  if (typeof column?.label === 'string' && column.label.length) {
    return column.label;
  }
  if (typeof column?.title === 'string') {
    return column.title;
  }
  const titleChildren = column?.title?.props?.children;
  if (typeof titleChildren === 'string') {
    return titleChildren;
  }
  return fallbackKey;
};

const TABLE_MODIFIERS = [
  'wrap',
  'truncate',
  'nowrap',
  'breakWord',
  'fitContent',
];
const HEADER_WRAP_MAX_WIDTH = '12ch';
const HEADER_TRUNCATE_MAX_WIDTH = '16ch';

export const countHeaderWords = label => {
  if (typeof label !== 'string' || !label.trim()) return 0;
  return label.trim().split(/\s+/).length;
};

/**
 * PatternFly Th modifier for a column header.
 * 1 word → nowrap, 2 words → wrap, 3+ words → truncate.
 * Override with column.headerModifier.
 * @param {Object} column
 * @param {string} fallbackKey
 * @returns {'wrap'|'truncate'|'nowrap'|'breakWord'|'fitContent'}
 */
export const getHeaderModifier = (column, fallbackKey) => {
  if (TABLE_MODIFIERS.includes(column?.headerModifier)) {
    return column.headerModifier;
  }
  const words = countHeaderWords(getColumnLabel(column, fallbackKey));
  if (words >= 3) return 'truncate';
  if (words === 2) return 'wrap';
  return 'nowrap';
};

/**
 * Inline style so wrap/truncate headers can shrink in an auto-layout table.
 * Override with column.headerMaxWidth (CSS length, e.g. '12ch').
 * @param {Object} column
 * @param {string} modifier
 * @returns {Object|undefined}
 */
export const getHeaderStyle = (column, modifier) => {
  if (column?.headerMaxWidth) {
    return { maxWidth: column.headerMaxWidth };
  }
  if (modifier === 'wrap') return { maxWidth: HEADER_WRAP_MAX_WIDTH };
  if (modifier === 'truncate') return { maxWidth: HEADER_TRUNCATE_MAX_WIDTH };
  return undefined;
};

/**
 * PatternFly Td modifier. Override with column.cellModifier.
 * Defaults to wrap so overflowing strings fold instead of spilling.
 * Use truncate (with PF tooltip) for long free-text, breakWord for
 * unbreakable values such as FQDNs and IPv6.
 * @param {Object} column
 * @returns {'wrap'|'truncate'|'nowrap'|'breakWord'|'fitContent'}
 */
export const getCellModifier = column => {
  if (TABLE_MODIFIERS.includes(column?.cellModifier)) {
    return column.cellModifier;
  }
  return 'wrap';
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
    keysToColumnNames[key] = getColumnLabel(columns[key], key);
  });
  columnNamesKeys.sort((a, b) => {
    const columnBWeight = columns[b]?.weight;
    const columnAWeight = columns[a]?.weight;
    if (columnAWeight === undefined && columnBWeight === undefined) {
      return 0;
    }
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
  allColumnData,
  contextData
) => {
  const filteredColumns = {};
  columnNames.forEach(key => {
    if (allColumnData[key]) {
      const shouldShowColumnInTable = checkColumnRelevancy(
        allColumnData[key]?.isRelevant,
        contextData
      );
      if (shouldShowColumnInTable) filteredColumns[key] = allColumnData[key];
    }
  });
  return filteredColumns;
};
