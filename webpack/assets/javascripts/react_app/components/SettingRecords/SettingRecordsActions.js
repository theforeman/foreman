import {
  LOAD_SETTING_RECORDS,
  SET_EDITING_SETTING,
} from './SettingRecordsConstants';

export const loadSettingRecords = settings => async dispatch =>
  dispatch({ type: LOAD_SETTING_RECORDS, payload: settings });

export const setSettingEditing = setting => async dispatch =>
  dispatch({ type: SET_EDITING_SETTING, payload: { setting } });
