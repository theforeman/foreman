import React from 'react';
import PropTypes from 'prop-types';
import { Td } from '@patternfly/react-table';

export const RowSelectTd = ({ rowData, selectOne, isSelected }) => (
  <Td
    select={{
      rowIndex: rowData.id,
      onSelect: (_event, isSelecting) => {
        selectOne(isSelecting, rowData.id, rowData);
      },
      isSelected: isSelected(rowData.id),
      disable: false,
    }}
  />
);

RowSelectTd.propTypes = {
  rowData: PropTypes.object.isRequired,
  selectOne: PropTypes.func.isRequired,
  isSelected: PropTypes.func.isRequired,
};
