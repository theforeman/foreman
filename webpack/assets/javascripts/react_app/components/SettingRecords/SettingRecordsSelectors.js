import { createSelector } from 'reselect';
import { propsToCamelCase } from '../../common/helpers';

const selectSettingRecords = (state) => state.settingRecords;
export const selectSettings = (state) => selectSettingRecords(state).settings;

export const selectSettingsByCategory = (category) =>
  createSelector(selectSettings, (settings) =>
    settings[category].map(propsToCamelCase)
  );

export const selectSettingById = (id, category) =>
  createSelector(selectSettingsByCategory(category), (settings) =>
    settings.find((setting) => setting.id === id)
  );

export const selectSettingEditing = (state) =>
  selectSettingRecords(state).editing;
