import React from 'react';
import TableSelectionHeaderCell from '../components/TableSelectionHeaderCell';
import { deprecate } from '../../../../common/DeprecationService';

let selectionHeaderCellFormatterDeprecationLogged = false;

const logSelectionHeaderCellFormatterDeprecation = () => {
  if (selectionHeaderCellFormatterDeprecationLogged) {
    return;
  }

  selectionHeaderCellFormatterDeprecationLogged = true;
  deprecate(
    'table/formatters/selectionHeaderCellFormatter',
    'TableIndexPage from foremanReact/components/PF4/TableIndexPage/TableIndexPage or Table from @patternfly/react-table',
    '5.2'
  );
};

export const selectionHeaderCellFormatter = (selectionController, label) => {
  logSelectionHeaderCellFormatterDeprecation();

  return (
    <TableSelectionHeaderCell
      label={label}
      checked={selectionController.allPageSelected()}
      onChange={selectionController.selectPage}
    />
  );
};

export default selectionHeaderCellFormatter;
