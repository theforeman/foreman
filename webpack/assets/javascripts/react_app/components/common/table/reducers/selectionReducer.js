import Immutable from 'seamless-immutable';
import { union } from 'lodash';
import {
  SELECT_ROWS,
  UNSELECT_ROWS,
  UNSELECT_ALL_ROWS,
  SELECT_ALL_ROWS,
  OPEN_SELECT_ALL,
} from '../constants/SelectionConstants';

const initialState = Immutable({
  selectedRows: [],
  allRowsSelected: false,
  showSelectAll: false,
});

const getSelectedRows = (state) => (state ? state.selectedRows : []);

export const selectionReducer =
  (currentTableID) =>
  (state = initialState, { tableID, type, payload }) => {
    if (tableID === undefined || tableID !== currentTableID) return state;

    switch (type) {
      case SELECT_ALL_ROWS:
        return state.merge({ allRowsSelected: true });
      case SELECT_ROWS:
        return state.merge({
          selectedRows: union(payload, getSelectedRows(state)),
        });
      case OPEN_SELECT_ALL:
        return state.merge({ showSelectAll: true });
      case UNSELECT_ROWS:
        if (state && state.allRowsSelected) {
          // User can unselect rows if only the page rows are selected
          return state.merge({
            selectedRows: payload.results
              .map((row) => row.id)
              .filter((row) => row !== payload.id),
            allRowsSelected: false,
            showSelectAll: false,
          });
        }
        return state.merge({
          selectedRows: state.selectedRows.filter((row) => row !== payload.id),
        });
      case UNSELECT_ALL_ROWS:
        return state.merge({
          selectedRows: [],
          allRowsSelected: false,
          showSelectAll: false,
        });
      default:
        return state;
    }
  };
export default selectionReducer;
