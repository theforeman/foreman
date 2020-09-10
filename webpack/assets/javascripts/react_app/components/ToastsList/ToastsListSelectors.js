export const selectToastsListState = state => state.toasts;
export const selectToastsListMessages = state =>
  selectToastsListState(state).messages;
