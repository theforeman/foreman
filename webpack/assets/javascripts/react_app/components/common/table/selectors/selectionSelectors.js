export const selectSelection = state => state.API;

export const selectSelectionByID = (state, tableID) =>
  selectSelection(state)[tableID] || {};

export const selectAllRowsSelected = (state, tableID) =>
  selectSelectionByID(state, tableID).allRowsSelected || false;

export const selectSelectedRows = (state, tableID) =>
  selectSelectionByID(state, tableID).selectedRows || [];

export const selectShowSelectAll = (state, tableID) =>
  selectSelectionByID(state, tableID).showSelectAll || false;
