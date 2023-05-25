import {
  selectRow,
  selectPage,
  unselectAllRows,
  unselectRow,
} from '../actions/selectionActions';

/**
 * @property {string} tableID - A string that represents the table in the store.
 * @property {boolean} allRowsSelected - A boolean that describes if all the rows available are selected.
 * This boolean is provided by the selection reducer and should be in the component's store.
 * @property {Object[]} rows - An array of row objects that are available in the current page of the table.
 * Each object should have an id.
 * @property {string[]} selectedRows - An array of the selected ids (if all rows are selected this can be empty).
 * This array is provided by the selection reducer and should be in the component's store.
 * @property {function} dispatch - Dispatch function from the Redux store.
 * Can be created using the `useDispatch()` hook.
 * This is used for the selection actions.
 */

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
