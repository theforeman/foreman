import React from 'react';
import PropTypes from 'prop-types';
import { Td } from '@patternfly/react-table';

export const RowSelectTd = ({
  rowData,
  selectOne,
  isSelected,
  isSelectable,
  idColumnName = 'id',
}) => {
  const isRowSelectable = isSelectable ? isSelectable(rowData) : true;

  return (
    <Td
      select={{
        rowIndex: rowData[idColumnName],
        onSelect: (_event, isSelecting) => {
          selectOne(isSelecting, rowData[idColumnName], rowData);
        },
        isSelected: isSelected(rowData[idColumnName]),
        isDisabled: !isRowSelectable,
      }}
    />
  );
};

RowSelectTd.propTypes = {
  rowData: PropTypes.object.isRequired,
  selectOne: PropTypes.func.isRequired,
  isSelected: PropTypes.func.isRequired,
  isSelectable: PropTypes.func,
  idColumnName: PropTypes.string,
};

RowSelectTd.defaultProps = {
  isSelectable: null,
  idColumnName: 'id',
};
