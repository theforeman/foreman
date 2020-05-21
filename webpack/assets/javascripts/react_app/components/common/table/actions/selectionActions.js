import {
  SELECT_ROWS,
  SELECT_ALL_ROWS,
  UNSELECT_ALL_ROWS,
  UNSELECT_ROWS,
  OPEN_SELECT_ALL,
} from '../constants/SelectionConstants';

export const selectPage = (tableID, results) => dispatch => {
  dispatch({
    type: SELECT_ROWS,
    payload: results.map(row => row.id),
    tableID,
  });
  dispatch({
    type: OPEN_SELECT_ALL,
    tableID,
  });
};

export const selectAllRows = tableID => ({
  type: SELECT_ALL_ROWS,
  tableID,
});

export const unselectAllRows = tableID => ({
  type: UNSELECT_ALL_ROWS,
  tableID,
});

export const selectRow = (tableID, id) => ({
  type: SELECT_ROWS,
  payload: [id],
  tableID,
});

export const unselectRow = (tableID, id, results) => ({
  type: UNSELECT_ROWS,
  payload: { id, results },
  tableID,
});
