import { SET_UPDATE_SETTING } from './SettingsTableConstants';

export const setSettingToUpdate = setting => async dispatch =>
  dispatch({ type: SET_UPDATE_SETTING, payload: { setting } });
