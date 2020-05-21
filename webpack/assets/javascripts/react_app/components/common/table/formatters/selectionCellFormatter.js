import React from 'react';
import TableSelectionCell from '../components/TableSelectionCell';

export const selectionCellFormatter = (selectionController, additionalData) => (
  <TableSelectionCell
    id={`select${additionalData.rowIndex}`}
    checked={selectionController.isSelected(additionalData)}
    onChange={() => selectionController.selectRow(additionalData)}
  />
);
export default selectionCellFormatter;
