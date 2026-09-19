const OPERATORS = ['!=', '!~', '!^', '>=', '<=', '=', '>', '<', '~', '^'];
const LOGICAL_OPERATORS = ['and', 'or', 'not', 'has'];

const escapeRegExp = str => str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');

const parseValue = value => {
  if (!value) return '';
  const trimmed = value.trim();
  if (
    (trimmed.startsWith('"') && trimmed.endsWith('"')) ||
    (trimmed.startsWith("'") && trimmed.endsWith("'"))
  ) {
    return trimmed.slice(1, -1);
  }
  return trimmed;
};

const formatValue = value => {
  if (!value) return '""';
  const stringValue = String(value);
  if (
    stringValue.includes(' ') ||
    stringValue.includes(',') ||
    stringValue.includes('(') ||
    stringValue.includes(')')
  ) {
    return `"${stringValue.replace(/"/g, '\\"')}"`;
  }
  return stringValue;
};

export const parseScopedSearchQuery = queryString => {
  if (!queryString || typeof queryString !== 'string') {
    return [];
  }

  const filters = [];
  let currentPos = 0;
  const query = queryString.trim();

  while (currentPos < query.length) {
    const remainingQuery = query.substring(currentPos).trim();

    const logicalMatch = LOGICAL_OPERATORS.find(op => {
      const pattern = new RegExp(`^${escapeRegExp(op)}\\s+`, 'i');
      return pattern.test(remainingQuery);
    });

    if (logicalMatch) {
      currentPos += logicalMatch.length + 1;
      while (currentPos < query.length && query[currentPos] === ' ') {
        currentPos++;
      }
    } else {
      let foundFilter = false;

      // eslint-disable-next-line no-unused-vars
      for (const operator of OPERATORS) {
        const operatorPattern = new RegExp(
          `^([^\\s]+)\\s*${escapeRegExp(operator)}\\s*`,
          'i'
        );
        const match = remainingQuery.match(operatorPattern);

        if (match) {
          const field = match[1];
          currentPos += match[0].length;

          let value = '';
          const valueQuery = query.substring(currentPos);

          if (valueQuery[0] === '"' || valueQuery[0] === "'") {
            const quoteChar = valueQuery[0];
            let endQuotePos = 1;
            while (
              endQuotePos < valueQuery.length &&
              valueQuery[endQuotePos] !== quoteChar
            ) {
              if (
                valueQuery[endQuotePos] === '\\' &&
                endQuotePos + 1 < valueQuery.length
              ) {
                endQuotePos += 2;
              } else {
                endQuotePos++;
              }
            }
            if (endQuotePos < valueQuery.length) {
              value = valueQuery.substring(0, endQuotePos + 1);
              currentPos += endQuotePos + 1;
            } else {
              value = valueQuery.substring(0, endQuotePos);
              currentPos += endQuotePos;
            }
          } else {
            const valueMatch = valueQuery.match(/^([^\s]+)/);
            if (valueMatch) {
              [, value] = valueMatch;
              currentPos += value.length;
            }
          }

          filters.push({
            field,
            operator,
            value: parseValue(value),
          });

          foundFilter = true;
          break;
        }
      }

      if (!foundFilter) {
        currentPos++;
      }

      while (currentPos < query.length && query[currentPos] === ' ') {
        currentPos++;
      }
    }
  }

  return filters;
};

export const convertFiltersToQuery = filters => {
  if (!Array.isArray(filters) || filters.length === 0) {
    return '';
  }

  return filters
    .map(({ field, operator, value }) => {
      if (!field || !operator) return '';
      return `${field} ${operator} ${formatValue(value)}`;
    })
    .filter(Boolean)
    .join(' and ');
};

export const updateFilterInQuery = (queryString, filterToUpdate, newFilter) => {
  const filters = parseScopedSearchQuery(queryString);
  const index = filters.findIndex(
    f =>
      f.field === filterToUpdate.field &&
      f.operator === filterToUpdate.operator &&
      f.value === filterToUpdate.value
  );

  if (index !== -1) {
    if (newFilter) {
      filters[index] = newFilter;
    } else {
      filters.splice(index, 1);
    }
  }

  return convertFiltersToQuery(filters);
};

export const removeFilterFromQuery = (queryString, filterToRemove) =>
  updateFilterInQuery(queryString, filterToRemove, null);

export const addFilterToQuery = (queryString, newFilter) => {
  const filters = parseScopedSearchQuery(queryString);
  filters.push(newFilter);
  return convertFiltersToQuery(filters);
};
