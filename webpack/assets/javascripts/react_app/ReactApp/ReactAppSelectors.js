export const selectReactApp = state => state.app;
export const selectReactAppMetadata = state => selectReactApp(state).metadata;
