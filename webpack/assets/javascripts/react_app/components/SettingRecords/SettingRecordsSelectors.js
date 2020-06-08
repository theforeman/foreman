import { propsToCamelCase } from '../../common/helpers';

const selectSettingRecords = state => state.settingRecords;
export const selectSettings = state => selectSettingRecords(state).settings;
export const selectSettingsByCategory = (state, category) =>
  selectSettings(state)[category].map(propsToCamelCase);
export const selectSettingById = (state, id, category) =>
  selectSettingsByCategory(state, category).find(setting => setting.id === id);
