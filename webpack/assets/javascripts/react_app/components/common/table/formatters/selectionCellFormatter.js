import React from 'react';
import TableSelectionCell from '../components/TableSelectionCell';
import { deprecate } from '../../../../common/DeprecationService';

let selectionCellFormatterDeprecationLogged = false;

const logSelectionCellFormatterDeprecation = () => {
  if (selectionCellFormatterDeprecationLogged) {
    return;
  }

  selectionCellFormatterDeprecationLogged = true;
  deprecate(
    'table/formatters/selectionCellFormatter',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

export const selectionCellFormatter = (selectionController, additionalData) => {
  logSelectionCellFormatterDeprecation();

  return (
    <TableSelectionCell
      id={`select${additionalData.rowIndex}`}
      checked={selectionController.isSelected(additionalData)}
      onChange={() => selectionController.selectRow(additionalData)}
    />
  );
};
export default selectionCellFormatter;
