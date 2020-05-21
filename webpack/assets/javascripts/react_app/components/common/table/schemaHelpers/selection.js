import {
  selectRow,
  selectPage,
  unselectAllRows,
  unselectRow,
} from '../actions/selectionActions';

export const getSelectionController = ({
  tableID,
  allRowsSelected,
  rows,
  selectedRows,
  dispatch,
}) => {
  const checkAllPageSelected = () =>
    allRowsSelected || rows.length === selectedRows.length;

  return {
    allRowsSelected,
    allPageSelected: () => checkAllPageSelected(tableID),
    selectPage: () => {
      if (checkAllPageSelected()) dispatch(unselectAllRows(tableID));
      else {
        dispatch(selectPage(tableID, rows));
      }
    },
    selectRow: ({ rowData: { id } }) => {
      if (selectedRows.includes(id) || allRowsSelected)
        dispatch(unselectRow(tableID, id, allRowsSelected && rows));
      else dispatch(selectRow(tableID, id));
    },
    isSelected: ({ rowData }) =>
      allRowsSelected || selectedRows.includes(rowData.id),
  };
};
