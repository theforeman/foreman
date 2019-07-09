import { GET_SETTING } from './SettingsConstants';
import { API_OPERATIONS } from '../../redux/API';

export const loadSetting = settingName => dispatch => {
  dispatch({
    type: API_OPERATIONS.GET,
    outputType: GET_SETTING,
    url: `/api/v2/settings/${settingName}`,
    successFormat: data => ({ data }),
  });
};

export default loadSetting;
