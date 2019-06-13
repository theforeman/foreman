export const selectReactApp = state => state.app;
export const selectReactAppMetadata = state => selectReactApp(state).metadata;

export const selectReactAppVersion = state =>
  selectReactAppMetadata(state).version;
export const selectReactAppPerPageOptions = state =>
  selectReactAppMetadata(state).perPageOptions;
