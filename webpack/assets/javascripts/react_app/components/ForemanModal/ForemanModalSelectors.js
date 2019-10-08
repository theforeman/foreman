export const selectForemanModalsState = state => state.foremanModals;
export const selectModalStateById = (state, id) =>
  state.foremanModals && state.foremanModals[id];
export const selectIsModalOpen = (state, id) => {
  const openState = selectModalStateById(state, id);
  return openState && openState.open;
};
