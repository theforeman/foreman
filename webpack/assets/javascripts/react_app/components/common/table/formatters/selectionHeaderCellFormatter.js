import React from 'react';
import TableSelectionHeaderCell from '../components/TableSelectionHeaderCell';

export const selectionHeaderCellFormatter = (selectionController, label) => (
  <TableSelectionHeaderCell
    label={label}
    checked={selectionController.allPageSelected()}
    onChange={selectionController.selectPage}
  />
);

export default selectionHeaderCellFormatter;
