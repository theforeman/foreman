import React from 'react';
import PropTypes from 'prop-types';
import { Td } from '@patternfly/react-table';

export const RowSelectTd = ({
  rowData,
  selectOne,
  isSelected,
  idColumnName = 'id',
}) => (
  <Td
    select={{
      rowIndex: rowData[idColumnName],
      onSelect: (_event, isSelecting) => {
        selectOne(isSelecting, rowData[idColumnName], rowData);
      },
      isSelected: isSelected(rowData[idColumnName]),
      disable: false,
    }}
  />
);

RowSelectTd.propTypes = {
  rowData: PropTypes.object.isRequired,
  selectOne: PropTypes.func.isRequired,
  isSelected: PropTypes.func.isRequired,
  idColumnName: PropTypes.string,
};

RowSelectTd.defaultProps = {
  idColumnName: 'id',
};
