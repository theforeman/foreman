export const selectReactApp = state => state.app;
export const selectReactAppMetadata = state => selectReactApp(state).metadata;
export const selectI18NReady = state => selectReactApp(state).i18nReady;

export const selectReactAppVersion = state =>
  selectReactAppMetadata(state).version;
export const selectReactAppPerPageOptions = state =>
  selectReactAppMetadata(state).perPageOptions;
