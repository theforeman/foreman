import { LOAD_SETTING_RECORDS } from './SettingRecordsConstants';

export const loadSettingRecords = settings => async dispatch =>
  dispatch({ type: LOAD_SETTING_RECORDS, payload: settings });
