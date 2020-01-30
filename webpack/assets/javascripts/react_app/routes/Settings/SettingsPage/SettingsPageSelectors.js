import Immutable from 'seamless-immutable';

import { groupSettings } from './SettingsPageHelpers';

export const selectSettingsPage = state => state.settingsPage.pageContent;

export const selectSettings = state =>
  selectSettingsPage(state).results || Immutable([]);

export const selectHasError = state => selectSettingsPage(state).hasError;
export const selectIsLoading = state => selectSettingsPage(state).isLoading;
export const selectHasData = state => selectSettingsPage(state).hasData;
export const selectErrorMsg = state => selectSettingsPage(state).message;

export const selectGroupedSettings = state =>
  groupSettings(selectSettings(state));

export const selectSettingGroup = state => group =>
  selectGroupedSettings(state)[group];
