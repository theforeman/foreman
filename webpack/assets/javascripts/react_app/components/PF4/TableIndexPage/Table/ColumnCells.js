import React from 'react';
import PropTypes from 'prop-types';
import { Th, Td } from '@patternfly/react-table';
import { getHeaderModifier, getHeaderStyle, getCellModifier } from './helpers';

export const ColumnHeaders = ({
  columns,
  columnNamesKeys,
  keysToColumnNames,
  columnsToSortParams,
  pfSortParams,
}) =>
  columnNamesKeys.map(k => {
    const headerModifier = getHeaderModifier(columns[k], k);
    const headerLabel = keysToColumnNames[k];
    return (
      <Th
        key={k}
        className={columns[k]?.className}
        modifier={headerModifier}
        style={getHeaderStyle(columns[k], headerModifier)}
        tooltip={
          columns[k]?.headerTooltip ||
          (headerModifier === 'truncate' ? headerLabel : undefined)
        }
        textCenter={columns[k]?.textCenter}
        sort={
          Object.values(columnsToSortParams).includes(k) &&
          pfSortParams?.(headerLabel)
        }
        aria-label={headerLabel}
      >
        {columns[k].title}
      </Th>
    );
  });

ColumnHeaders.propTypes = {
  columns: PropTypes.object.isRequired,
  columnNamesKeys: PropTypes.array.isRequired,
  keysToColumnNames: PropTypes.object.isRequired,
  columnsToSortParams: PropTypes.object.isRequired,
  pfSortParams: PropTypes.func,
};

ColumnHeaders.defaultProps = {
  pfSortParams: null,
};

export const ColumnCells = ({
  columns,
  columnNamesKeys,
  keysToColumnNames,
  result,
}) =>
  columnNamesKeys.map(k => {
    const cellModifier = getCellModifier(columns[k]);
    return (
      <Td
        key={k}
        className={columns[k]?.className}
        dataLabel={keysToColumnNames[k]}
        textCenter={columns[k]?.textCenter}
        modifier={cellModifier}
        tooltip={cellModifier === 'truncate' ? undefined : null}
      >
        {columns[k].wrapper ? columns[k].wrapper(result) : result[k]}
      </Td>
    );
  });

ColumnCells.propTypes = {
  columns: PropTypes.object.isRequired,
  columnNamesKeys: PropTypes.array.isRequired,
  keysToColumnNames: PropTypes.object.isRequired,
  result: PropTypes.object.isRequired,
};
