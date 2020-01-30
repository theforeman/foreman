export const selectTestEmailState = state => state.settingsPage.testEmail;
export const selectTestEmailLoading = state =>
  selectTestEmailState(state).loading;
