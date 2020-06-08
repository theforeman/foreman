const selectSettingsTableState = state => state.settingsTable;
export const selectSettingToEdit = state =>
  selectSettingsTableState(state).toEdit;
