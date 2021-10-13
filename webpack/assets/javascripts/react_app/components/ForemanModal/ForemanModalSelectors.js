export const selectForemanModalsState = (state) => state.foremanModals;
export const selectModalStateById = (state, id) =>
  state.foremanModals && (state.foremanModals[id] || {});
export const selectIsModalOpen = (state, id) =>
  selectModalStateById(state, id).isOpen;
export const selectIsModalSubmitting = (state, id) =>
  selectModalStateById(state, id).isSubmitting;
export const selectModalExists = (state, id) =>
  Object.keys(selectModalStateById(state, id)).length > 0;
